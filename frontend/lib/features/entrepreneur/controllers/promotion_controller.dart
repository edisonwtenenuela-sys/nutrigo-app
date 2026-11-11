import 'dart:async';
import 'package:emprendedor/data/models/entrepreneur/index.dart';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:emprendedor/data/repositories/entrepreneur/promotions/promotion_repository.dart';

class PromotionController extends ChangeNotifier {
  final Logger _logger = Logger('PromotionController');
  final PromotionRepository _repository = PromotionRepository();

  List<PromotionModel> promotions = [];

  bool isLoading = false;
  bool hasLoadedPromotions = false;
  String? errorMessage;

  String? _userId;
  StreamSubscription<List<PromotionModel>>? _subscription;

  String? get userId => _userId;
  bool get hasUserId => _userId != null;

  Future<void> setUserId(String? userId) async {
    if (_userId == userId) return;

    await _subscription?.cancel();
    _subscription = null;

    _userId = userId;
    promotions = [];
    errorMessage = null;
    hasLoadedPromotions = false;

    if (_userId == null || _userId!.trim().isEmpty) {
      _setLoading(false);
      hasLoadedPromotions = true;
      notifyListeners();
      return;
    }

    await fetchPromotions();
  }

  Future<void> reset() async {
    await _subscription?.cancel();
    _subscription = null;

    promotions = [];
    errorMessage = null;
    isLoading = false;
    hasLoadedPromotions = false;
    _userId = null;

    notifyListeners();
  }

  Future<void> fetchPromotions() async {
    if (_userId == null || _userId!.trim().isEmpty) {
      hasLoadedPromotions = true;
      _setLoading(false);
      _setError('Usuario no autenticado.');
      return;
    }

    _setLoading(true);
    _clearError();

    await _subscription?.cancel();
    _subscription = null;

    try {
      _subscription = _repository
          .getPromotions(_userId!)
          .listen(
            (data) {
              promotions = data;
              hasLoadedPromotions = true;
              _setLoading(false);
              notifyListeners();
            },
            onError: (error, stackTrace) {
              _logger.severe('Error cargando promociones', error, stackTrace);
              hasLoadedPromotions = true;
              _setError('Error al cargar promociones.');
              _setLoading(false);
            },
          );
    } catch (e, st) {
      _logger.severe('Excepción cargando promociones', e, st);
      hasLoadedPromotions = true;
      _setError('Error al iniciar carga de promociones.');
      _setLoading(false);
    }
  }

  Future<bool> createOrUpdatePromotionFromForm({
    String? id,
    required String name,
    required String description,
    required DiscountType discountType,
    required double discountValue,
    required DateTime startDate,
    required DateTime endDate,
    required PromotionScope scope,
    required List<String> productIds,
  }) async {
    if (_userId == null || _userId!.trim().isEmpty) {
      _setError('Usuario no autenticado.');
      return false;
    }

    final promotion = PromotionModel.create(
      id: id,
      name: name,
      description: description,
      discountType: discountType,
      discountValue: discountValue,
      startDate: startDate,
      endDate: endDate,
      userId: _userId!,
      scope: scope,
      productIds: scope == PromotionScope.all ? const [] : productIds,
    );

    return createOrUpdatePromotion(promotion);
  }

  Future<bool> createOrUpdatePromotion(PromotionModel promotion) async {
    if (_userId == null || _userId!.trim().isEmpty) {
      _setError('Usuario no autenticado.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      if (promotion.id == null || promotion.id!.isEmpty) {
        await _repository.createPromotion(promotion, _userId!);
      } else {
        await _repository.updatePromotion(promotion, _userId!);
      }

      return true;
    } catch (e, st) {
      _logger.severe('Error guardando promoción', e, st);
      _setError('No se pudo guardar la promoción. ${friendlyErrorMessage(e)}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deletePromotion(String promotionId) async {
    if (_userId == null || _userId!.trim().isEmpty) {
      _setError('Usuario no autenticado.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await _repository.deletePromotion(promotionId, _userId!);
      return true;
    } catch (e, st) {
      _logger.severe('Error eliminando promoción', e, st);
      _setError('No se pudo eliminar la promoción. ${friendlyErrorMessage(e)}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Stream<List<CouponModel>> getCoupons(String promotionId) {
    if (_userId == null || _userId!.trim().isEmpty) {
      return const Stream.empty();
    }

    return _repository.getCouponsForPromotion(promotionId, _userId!);
  }

  Future<bool> createCouponFromPromotion({
    required PromotionModel promotion,
    required String code,
    required DateTime validityDate,
    required double minimumPurchase,
  }) async {
    final promotionId = promotion.id;
    if (promotionId == null || promotionId.trim().isEmpty) {
      _setError('Promoción inválida.');
      return false;
    }

    final coupon = CouponModel.create(
      code: code,
      promotionId: promotionId,
      discountValue: promotion.discountValue,
      validityDate: validityDate,
      minimumPurchase: minimumPurchase,
      userId: _userId,
    );

    return createCoupon(coupon);
  }

  Future<bool> createCoupon(CouponModel coupon) async {
    if (_userId == null || _userId!.trim().isEmpty) {
      _setError('Usuario no autenticado.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final couponWithUser = coupon.copyWith(userId: _userId);
      await _repository.createCoupon(couponWithUser, _userId!);
      return true;
    } catch (e, st) {
      _logger.severe('Error creando cupón', e, st);
      _setError('No se pudo crear el cupón. ${friendlyErrorMessage(e)}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCoupon(CouponModel coupon) async {
    if (_userId == null || _userId!.trim().isEmpty) {
      _setError('Usuario no autenticado.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final couponWithUser = coupon.copyWith(userId: _userId);
      await _repository.updateCoupon(couponWithUser, _userId!);
      return true;
    } catch (e, st) {
      _logger.severe('Error actualizando cupón', e, st);
      _setError('No se pudo actualizar el cupón. ${friendlyErrorMessage(e)}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCoupon(String promotionId, String couponId) async {
    if (_userId == null || _userId!.trim().isEmpty) {
      _setError('Usuario no autenticado.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await _repository.deleteCoupon(promotionId, couponId, _userId!);
      return true;
    } catch (e, st) {
      _logger.severe('Error eliminando cupón', e, st);
      _setError('No se pudo eliminar el cupón. ${friendlyErrorMessage(e)}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _clearError();
  }

  void _setLoading(bool value) {
    if (isLoading == value) return;
    isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    if (errorMessage == message) return;
    errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    if (errorMessage == null) return;
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
