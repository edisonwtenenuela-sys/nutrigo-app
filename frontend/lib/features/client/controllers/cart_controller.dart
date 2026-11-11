import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:emprendedor/data/models/entrepreneur/index.dart';

import 'package:emprendedor/data/models/shared/cart_item_model.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/data/models/shared/user_model.dart';
import 'package:emprendedor/data/repositories/shared/order_repository.dart';

class CartController extends ChangeNotifier {
  final Map<String, CartItemModel> _items = {};
  final OrderRepository _orderRepository = OrderRepository();
  final Logger _logger = Logger('CartController');
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _cartSubscription;
  String? _cartSubscriptionUserId;

  bool _isProcessingOrder = false;
  bool get isProcessingOrder => _isProcessingOrder;

  bool _isApplyingCoupon = false;
  bool get isApplyingCoupon => _isApplyingCoupon;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _couponMessage;
  String? get couponMessage => _couponMessage;

  String? _couponNotice;
  String? get couponNotice => _couponNotice;

  CouponModel? _appliedCoupon;
  CouponModel? get appliedCoupon => _appliedCoupon;

  PromotionModel? _appliedPromotion;
  PromotionModel? get appliedPromotion => _appliedPromotion;

  DocumentReference<Map<String, dynamic>>? _appliedCouponRef;
  bool _manualCouponApplied = false;
  int _automaticCouponRequestId = 0;
  final Map<String, List<_CouponSearchResult>> _automaticCouponOptionsCache =
      {};

  List<CartItemModel> get items => _items.values.toList();

  double get subtotal =>
      _items.values.fold(0.0, (acc, item) => acc + item.total);
  double get total => subtotal;

  int get itemCount =>
      _items.values.fold(0, (acc, item) => acc + item.quantity);

  String? get currentBusinessId => _firstBusinessId();

  bool hasDifferentBusiness(CartItemModel item) {
    final current = _firstBusinessId()?.trim();
    final incoming = item.productOwnerId?.trim();

    if (current == null || current.isEmpty) return false;
    if (incoming == null || incoming.isEmpty) return false;
    if (_items.containsKey(item.productId)) return false;

    return current != incoming;
  }

  Future<void> replaceCartWithProduct(CartItemModel item) async {
    await clearCart();
    await addProduct(item);
  }

  bool get hasCouponApplied => _appliedCoupon != null && discountAmount > 0;
  String? get appliedCouponCode => _appliedCoupon?.code;

  String get discountLabel {
    final promotion = _appliedPromotion;
    if (promotion == null || discountAmount <= 0) return 'Descuento';

    return switch (promotion.discountType) {
      DiscountType.percentage =>
        'Descuento ${_formatDiscountNumber(promotion.discountValue)}%',
      DiscountType.fixed =>
        'Descuento \$${promotion.discountValue.toStringAsFixed(2)}',
    };
  }

  String _formatDiscountNumber(double value) {
    if (value % 1 == 0) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }

  double get eligibleSubtotal {
    final promotion = _appliedPromotion;
    if (promotion == null) return subtotal;
    return _eligibleSubtotalFor(promotion);
  }

  double get discountAmount {
    final coupon = _appliedCoupon;
    final promotion = _appliedPromotion;
    if (coupon == null || promotion == null) return 0.0;

    return _discountFor(coupon: coupon, promotion: promotion);
  }

  double get finalTotal {
    final result = subtotal - discountAmount;
    return result < 0 ? 0.0 : double.parse(result.toStringAsFixed(2));
  }

  double _eligibleSubtotalFor(PromotionModel promotion) {
    if (promotion.scope == PromotionScope.all) return subtotal;

    return _items.values.fold(0.0, (acc, item) {
      return promotion.appliesToProduct(item.productId)
          ? acc + item.total
          : acc;
    });
  }

  double _discountFor({
    required CouponModel coupon,
    required PromotionModel promotion,
  }) {
    if (subtotal < coupon.minimumPurchase) return 0.0;

    final baseAmount = _eligibleSubtotalFor(promotion);
    if (baseAmount <= 0) return 0.0;

    final discount = switch (promotion.discountType) {
      DiscountType.percentage => baseAmount * (promotion.discountValue / 100),
      DiscountType.fixed => promotion.discountValue,
    };

    final boundedDiscount = discount > baseAmount ? baseAmount : discount;
    return double.parse(boundedDiscount.toStringAsFixed(2));
  }

  bool _applyBestCachedAutomaticCoupon() {
    if (_manualCouponApplied) return false;

    final businessId = _firstBusinessId()?.trim();
    if (businessId == null || businessId.isEmpty) return false;

    final options = _automaticCouponOptionsCache[businessId];
    if (options == null || options.isEmpty) return false;

    _CouponSearchResult? bestResult;
    var bestDiscount = 0.0;
    double? nearestMinimumPurchase;

    for (final option in options) {
      if (!option.coupon.canBeUsed || !option.promotion.isActiveNow) continue;

      if (subtotal < option.coupon.minimumPurchase) {
        nearestMinimumPurchase = nearestMinimumPurchase == null
            ? option.coupon.minimumPurchase
            : nearestMinimumPurchase < option.coupon.minimumPurchase
            ? nearestMinimumPurchase
            : option.coupon.minimumPurchase;
        continue;
      }

      final validationMessage = _automaticCouponValidationMessage(
        coupon: option.coupon,
        promotion: option.promotion,
      );
      if (validationMessage != null) continue;

      final discount = _discountFor(
        coupon: option.coupon,
        promotion: option.promotion,
      );
      if (discount > bestDiscount) {
        bestDiscount = discount;
        bestResult = option;
      }
    }

    if (bestResult != null && bestDiscount > 0) {
      _appliedCoupon = bestResult.coupon;
      _appliedPromotion = bestResult.promotion;
      _appliedCouponRef = null;
      _manualCouponApplied = false;
      _couponMessage = null;
      _couponNotice = null;
      return true;
    }

    if (_appliedCoupon != null || _appliedPromotion != null) {
      _clearAppliedCouponState();
    }
    _couponNotice = _promotionNoticeForMinimum(nearestMinimumPurchase);
    return false;
  }

  CollectionReference<Map<String, dynamic>> _cartRef(String uid) {
    return _db.collection('carts').doc(uid).collection('items');
  }

  String? _currentUserId() => FirebaseAuth.instance.currentUser?.uid;

  Future<void> loadCart() async {
    final uid = _currentUserId();
    if (uid == null) return;

    try {
      final snapshot = await _cartRef(uid).get();
      _replaceCartItems(snapshot.docs);
      _validateAppliedCouponLocally();
      notifyListeners();
      await _syncAutomaticCoupon();
    } catch (e) {
      _logger.warning('Error cargando carrito: $e');
    }
  }

  Future<void> watchCart() async {
    final uid = _currentUserId();
    if (uid == null) return;
    if (_cartSubscription != null && _cartSubscriptionUserId == uid) return;

    await _cartSubscription?.cancel();
    _cartSubscriptionUserId = uid;
    _cartSubscription = _cartRef(uid).snapshots().listen(
      (snapshot) {
        _replaceCartItems(snapshot.docs);
        _validateAppliedCouponLocally();
        notifyListeners();
        unawaited(_syncAutomaticCoupon());
      },
      onError: (Object e, StackTrace stackTrace) {
        _logger.warning('Error escuchando carrito', e, stackTrace);
      },
    );
  }

  void _replaceCartItems(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    _items.clear();
    for (final doc in docs) {
      final item = CartItemModel.fromMap(doc.data());
      _items[item.productId] = item;
    }
  }

  Future<void> addProduct(CartItemModel item) async {
    final uid = _currentUserId();
    if (uid == null) return;

    if (_items.containsKey(item.productId)) {
      _items[item.productId]!.quantity++;
    } else {
      _items[item.productId] = item;
    }

    _validateAppliedCouponLocally();
    _applyBestCachedAutomaticCoupon();
    notifyListeners();

    try {
      await _cartRef(
        uid,
      ).doc(item.productId).set(_items[item.productId]!.toMap());
    } catch (e) {
      _logger.warning('Error guardando producto en carrito: $e');
    }

    await _syncAutomaticCoupon();
  }

  Future<void> removeProduct(String productId) async {
    final uid = _currentUserId();
    if (uid == null) return;

    _items.remove(productId);
    _validateAppliedCouponLocally();
    _applyBestCachedAutomaticCoupon();
    notifyListeners();

    try {
      await _cartRef(uid).doc(productId).delete();
    } catch (e) {
      _logger.warning('Error eliminando producto del carrito: $e');
    }

    await _syncAutomaticCoupon();
  }

  Future<void> increaseQuantity(String productId) async {
    await _updateItemQuantity(productId: productId, increment: 1);
  }

  Future<void> decreaseQuantity(String productId) async {
    await _updateItemQuantity(productId: productId, increment: -1);
  }

  Future<void> _updateItemQuantity({
    required String productId,
    required int increment,
  }) async {
    final uid = _currentUserId();
    if (uid == null || !_items.containsKey(productId)) return;

    final item = _items[productId]!;
    final nextQuantity = item.quantity + increment;

    if (nextQuantity > 0) {
      item.quantity = nextQuantity;
    } else {
      _items.remove(productId);
    }

    _validateAppliedCouponLocally();
    _applyBestCachedAutomaticCoupon();
    notifyListeners();

    try {
      if (nextQuantity > 0) {
        await _cartRef(uid).doc(productId).set(_items[productId]!.toMap());
      } else {
        await _cartRef(uid).doc(productId).delete();
      }
    } catch (e) {
      _logger.warning('Error actualizando cantidad del carrito: $e');
    }

    await _syncAutomaticCoupon();
  }

  Future<void> clearCart() async {
    final uid = _currentUserId();
    if (uid == null) return;

    try {
      final snapshot = await _cartRef(
        uid,
      ).get().timeout(const Duration(seconds: 8));
      for (final doc in snapshot.docs) {
        await doc.reference.delete().timeout(const Duration(seconds: 5));
      }
    } catch (e, st) {
      _logger.warning('No se pudo limpiar el carrito remoto.', e, st);
    } finally {
      _items.clear();
      _automaticCouponRequestId++;
      _automaticCouponOptionsCache.clear();
      removeCoupon(notify: false);
      notifyListeners();
    }
  }

  Future<bool> applyCoupon(String rawCode) async {
    final code = rawCode.trim().toUpperCase();
    if (!_validateCouponInput(code)) return false;

    final businessId = _firstBusinessId();
    if (businessId == null || businessId.trim().isEmpty) {
      _setCouponMessage('No se pudo identificar el negocio.');
      return false;
    }

    _isApplyingCoupon = true;
    _couponMessage = null;
    _couponNotice = null;
    notifyListeners();

    try {
      final found = await _findValidCoupon(businessId: businessId, code: code);

      if (found == null) {
        _clearAppliedCouponState();
        _couponNotice = null;
        _couponMessage = 'Cupón no encontrado.';
        return false;
      }

      _appliedCoupon = found.coupon;
      _appliedPromotion = found.promotion;
      _appliedCouponRef = found.couponRef;
      _manualCouponApplied = true;
      _couponMessage = 'Cupón aplicado correctamente.';
      _couponNotice = null;
      return true;
    } catch (e, st) {
      _logger.warning('Error aplicando cupón', e, st);
      _clearAppliedCouponState();
      _couponNotice = null;
      _couponMessage = 'No se pudo validar el cupón.';
      return false;
    } finally {
      _isApplyingCoupon = false;
      notifyListeners();
    }
  }

  void removeCoupon({bool notify = true}) {
    _clearAppliedCouponState();
    _couponMessage = null;
    _couponNotice = null;
    if (notify) notifyListeners();
  }

  void _validateAppliedCouponLocally() {
    final coupon = _appliedCoupon;
    final promotion = _appliedPromotion;
    if (coupon == null || promotion == null) return;

    if (_items.isEmpty) {
      removeCoupon(notify: false);
      return;
    }

    if (subtotal < coupon.minimumPurchase) {
      if (_manualCouponApplied) {
        _couponMessage =
            'El cupón fue removido porque ya no alcanzas la compra mínima.';
        _clearAppliedCouponState();
      }
      return;
    }

    final appliesToCart = _items.values.any(
      (item) => promotion.appliesToProduct(item.productId),
    );

    if (!appliesToCart) {
      _couponMessage = _manualCouponApplied
          ? 'El cupón fue removido porque ya no aplica a los productos del carrito.'
          : null;
      _clearAppliedCouponState();
    }
  }

  Future<OrderModel?> confirmOrder({
    required String shippingAddress,
    required String paymentMethod,
    required String customerName,
    required String customerEmail,
    String? customerPhoneNumber,
    String? customerProfileImageUrl,
    PaymentStatus paymentStatus = PaymentStatus.pending,
    String? paymentIntentId,
    double? latitude,
    double? longitude,
  }) async {
    if (_isProcessingOrder) return null;

    final uid = _currentUserId();
    if (uid == null) {
      _setError('No autenticado');
      return null;
    }

    if (_items.isEmpty) {
      _setError('Carrito vacío');
      return null;
    }

    _setProcessing(true);
    _clearError();

    try {
      final businessId = _firstBusinessId();
      if (businessId == null || businessId.trim().isEmpty) {
        _setError('No se pudo identificar el negocio.');
        return null;
      }

      final order = OrderModel(
        userId: uid,
        businessUserId: businessId,
        items: _buildOrderItems(),
        totalPrice: finalTotal,
        originalTotal: subtotal,
        discountAmount: discountAmount,
        finalTotal: finalTotal,
        status: OrderStatus.pending,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        paymentIntentId: paymentIntentId,
        latitude: latitude,
        longitude: longitude,
        couponId: _appliedCoupon?.id,
        couponCode: _appliedCoupon?.code,
        promotionId: _appliedPromotion?.id,
        customerInfo: UserModel(
          id: uid,
          name: customerName,
          email: customerEmail,
          phoneNumber: customerPhoneNumber,
          profileImageUrl: customerProfileImageUrl,
        ),
        createdAt: Timestamp.now(),
      );

      final orderRef = await _orderRepository
          .addOrder(order)
          .timeout(const Duration(seconds: 12));
      final createdOrder =
          await _orderRepository.waitForClientOrderNumber(
            orderId: orderRef.id,
            userId: uid,
          ) ??
          order.copyWith(id: orderRef.id);

      if (_manualCouponApplied &&
          _appliedCoupon != null &&
          _appliedCouponRef != null) {
        await _appliedCouponRef!
            .update({
              'isUsed': true,
              'status': CouponStatus.used.name,
              'usedByUserId': uid,
              'usedInOrderId': orderRef.id,
              'usedAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            })
            .timeout(const Duration(seconds: 6));
      }

      await clearCart();
      return createdOrder;
    } catch (e, st) {
      _logger.severe('Error al crear pedido', e, st);
      _setError('Error al procesar pedido');
      return null;
    } finally {
      _setProcessing(false);
    }
  }

  List<OrderItem> _buildOrderItems() {
    return _items.values
        .map(
          (item) => OrderItem(
            productId: item.productId,
            productName: item.name,
            quantity: item.quantity,
            priceAtPurchase: item.price,
            imageUrl: item.imageUrl,
          ),
        )
        .toList();
  }

  String? _firstBusinessId() {
    if (_items.isEmpty) return null;
    return _items.values.first.productOwnerId;
  }

  bool _validateCouponInput(String code) {
    if (code.isEmpty) {
      _setCouponMessage('Ingresa un código de cupón.');
      return false;
    }

    if (_items.isEmpty) {
      _setCouponMessage('Agrega productos antes de aplicar un cupón.');
      return false;
    }

    return true;
  }

  Future<_CouponSearchResult?> _findValidCoupon({
    required String businessId,
    required String code,
  }) async {
    final promotionsSnapshot = await _db
        .collection('promotions')
        .where('userId', isEqualTo: businessId)
        .where('status', isEqualTo: PromotionStatus.active.name)
        .get();

    for (final promoDoc in promotionsSnapshot.docs) {
      final promotion = PromotionModel.fromFirestore(promoDoc);
      if (!promotion.isActiveNow) continue;

      final couponSnapshot = await promoDoc.reference
          .collection('coupons')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();
      if (couponSnapshot.docs.isEmpty) continue;

      final couponDoc = couponSnapshot.docs.first;
      final coupon = CouponModel.fromFirestore(couponDoc);

      final validationMessage = _couponValidationMessage(
        coupon: coupon,
        promotion: promotion,
      );
      if (validationMessage != null) {
        _clearAppliedCouponState();
        _couponMessage = validationMessage;
        return null;
      }

      return _CouponSearchResult(
        coupon: coupon.copyWith(id: couponDoc.id, promotionId: promoDoc.id),
        promotion: promotion.copyWith(id: promoDoc.id),
        couponRef: couponDoc.reference,
      );
    }

    return null;
  }

  Future<void> _syncAutomaticCoupon() async {
    if (_manualCouponApplied) return;

    final businessId = _firstBusinessId();
    if (_items.isEmpty || businessId == null || businessId.trim().isEmpty) {
      if (_appliedCoupon != null || _appliedPromotion != null) {
        _clearAppliedCouponState();
        _couponNotice = null;
        notifyListeners();
      }
      return;
    }

    final requestId = ++_automaticCouponRequestId;

    try {
      final found = await _findBestAutomaticCoupon(businessId: businessId);
      if (requestId != _automaticCouponRequestId) return;

      if (found == null) {
        if (_appliedCoupon != null || _appliedPromotion != null) {
          _clearAppliedCouponState();
        }
        notifyListeners();
        return;
      }

      _appliedCoupon = found.coupon;
      _appliedPromotion = found.promotion;
      _appliedCouponRef = null;
      _manualCouponApplied = false;
      _couponMessage = null;
      _couponNotice = null;
      notifyListeners();
    } catch (e, st) {
      _logger.warning('Error sincronizando promoción automática', e, st);
    }
  }

  Future<_CouponSearchResult?> _findBestAutomaticCoupon({
    required String businessId,
  }) async {
    final cachedOptions = _automaticCouponOptionsCache[businessId];
    if (cachedOptions != null) {
      _applyBestCachedAutomaticCoupon();
      return _appliedCoupon == null || _appliedPromotion == null
          ? null
          : _CouponSearchResult(
              coupon: _appliedCoupon!,
              promotion: _appliedPromotion!,
              couponRef: _appliedCouponRef,
            );
    }

    final promotionsSnapshot = await _db
        .collection('promotions')
        .where('userId', isEqualTo: businessId)
        .where('status', isEqualTo: PromotionStatus.active.name)
        .get();

    _CouponSearchResult? bestResult;
    final options = <_CouponSearchResult>[];
    var bestDiscount = -1.0;
    double? nearestMinimumPurchase;

    for (final promoDoc in promotionsSnapshot.docs) {
      final promotion = PromotionModel.fromFirestore(promoDoc);
      if (!promotion.isActiveNow) continue;

      final couponSnapshot = await promoDoc.reference
          .collection('coupons')
          .get();
      for (final couponDoc in couponSnapshot.docs) {
        final coupon = CouponModel.fromFirestore(couponDoc);
        final validationMessage = _automaticCouponValidationMessage(
          coupon: coupon,
          promotion: promotion,
        );
        if (validationMessage != null) continue;

        final promotionWithId = promotion.copyWith(id: promoDoc.id);
        final couponWithId = coupon.copyWith(
          id: couponDoc.id,
          promotionId: promoDoc.id,
        );
        final option = _CouponSearchResult(
          coupon: couponWithId,
          promotion: promotionWithId,
          couponRef: couponDoc.reference,
        );
        options.add(option);

        if (subtotal < coupon.minimumPurchase) {
          nearestMinimumPurchase = nearestMinimumPurchase == null
              ? coupon.minimumPurchase
              : nearestMinimumPurchase < coupon.minimumPurchase
              ? nearestMinimumPurchase
              : coupon.minimumPurchase;
          continue;
        }

        final discount = _potentialDiscountFor(promotionWithId);
        if (discount <= 0) continue;

        if (discount > bestDiscount) {
          bestDiscount = discount;
          bestResult = option;
        }
      }
    }

    _automaticCouponOptionsCache[businessId] = options;
    _couponNotice = _promotionNoticeForMinimum(nearestMinimumPurchase);
    return bestResult;
  }

  String? _promotionNoticeForMinimum(double? minimumPurchase) {
    if (minimumPurchase == null || minimumPurchase <= subtotal) return null;

    final missingAmount = minimumPurchase - subtotal;
    return 'Agrega \$${missingAmount.toStringAsFixed(2)} más para activar una promoción disponible.';
  }

  double _potentialDiscountFor(PromotionModel promotion) {
    final baseAmount = _eligibleSubtotalFor(promotion);
    if (baseAmount <= 0) return 0.0;

    final discount = switch (promotion.discountType) {
      DiscountType.percentage => baseAmount * (promotion.discountValue / 100),
      DiscountType.fixed => promotion.discountValue,
    };

    return discount > baseAmount ? baseAmount : discount;
  }

  String? _automaticCouponValidationMessage({
    required CouponModel coupon,
    required PromotionModel promotion,
  }) {
    if (!coupon.canBeUsed) {
      return 'Este cupón no está disponible o ya fue usado.';
    }

    final appliesToCart = _items.values.any(
      (item) => promotion.appliesToProduct(item.productId),
    );
    if (!appliesToCart) {
      return 'Este cupón no aplica a los productos del carrito.';
    }

    return null;
  }

  String? _couponValidationMessage({
    required CouponModel coupon,
    required PromotionModel promotion,
  }) {
    if (!coupon.canBeUsed) {
      return 'Este cupón no está disponible o ya fue usado.';
    }

    if (subtotal < coupon.minimumPurchase) {
      return 'Compra mínima requerida: \$${coupon.minimumPurchase.toStringAsFixed(2)}.';
    }

    final appliesToCart = _items.values.any(
      (item) => promotion.appliesToProduct(item.productId),
    );
    if (!appliesToCart) {
      return 'Este cupón no aplica a los productos del carrito.';
    }

    return null;
  }

  void _clearAppliedCouponState() {
    _appliedCoupon = null;
    _appliedPromotion = null;
    _appliedCouponRef = null;
    _manualCouponApplied = false;
  }

  void _setCouponMessage(String message) {
    _couponMessage = message;
    _couponNotice = null;
    notifyListeners();
  }

  void _setProcessing(bool value) {
    _isProcessingOrder = value;
    notifyListeners();
  }

  void clearProcessingState() {
    if (!_isProcessingOrder) return;
    _isProcessingOrder = false;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> reset() async {
    await _cartSubscription?.cancel();
    _cartSubscription = null;
    _cartSubscriptionUserId = null;
    _items.clear();
    _isProcessingOrder = false;
    _isApplyingCoupon = false;
    _errorMessage = null;
    _couponMessage = null;
    _couponNotice = null;
    _automaticCouponRequestId++;
    _clearAppliedCouponState();
    notifyListeners();
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }
}

class _CouponSearchResult {
  final CouponModel coupon;
  final PromotionModel promotion;
  final DocumentReference<Map<String, dynamic>>? couponRef;

  const _CouponSearchResult({
    required this.coupon,
    required this.promotion,
    required this.couponRef,
  });
}
