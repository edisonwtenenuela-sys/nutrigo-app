import 'package:emprendedor/data/models/entrepreneur/index.dart';
import 'package:emprendedor/data/repositories/entrepreneur/promotions/promotion_repository.dart';

class ProductPromotionInfo {
  final PromotionModel promotion;
  final CouponModel? coupon;

  const ProductPromotionInfo({required this.promotion, this.coupon});

  double discountFor(double price) {
    double discount = 0;

    switch (promotion.discountType) {
      case DiscountType.percentage:
        discount = price * (promotion.discountValue / 100);
        break;
      case DiscountType.fixed:
        discount = promotion.discountValue;
        break;
    }

    if (discount > price) return price;

    return double.parse(discount.toStringAsFixed(2));
  }

  double finalPrice(double price) {
    return double.parse((price - discountFor(price)).toStringAsFixed(2));
  }

  double get minimumPurchase => coupon?.minimumPurchase ?? 0.0;

  bool get hasMinimumPurchase => minimumPurchase > 0;

  bool isDiscountAvailableFor(double amount) {
    return !hasMinimumPurchase || amount >= minimumPurchase;
  }

  String get availabilityLabel {
    if (!hasMinimumPurchase) return discountLabel;
    return '$compactDiscountLabel desde ${_moneyLabel(minimumPurchase)}';
  }

  String get compactDiscountLabel {
    if (promotion.discountType == DiscountType.percentage) {
      return '${promotion.discountValue.toStringAsFixed(0)}%';
    }

    return '-${_moneyLabel(promotion.discountValue)}';
  }

  String _moneyLabel(double value) {
    final isWhole = value == value.roundToDouble();
    return '\$${isWhole ? value.toStringAsFixed(0) : value.toStringAsFixed(2)}';
  }

  String get discountLabel {
    if (promotion.discountType == DiscountType.percentage) {
      return '${promotion.discountValue.toStringAsFixed(0)}% OFF';
    }

    return '\$${promotion.discountValue.toStringAsFixed(2)} OFF';
  }
}

class ClientProductPromotionController {
  ClientProductPromotionController({PromotionRepository? repository})
    : _repository = repository ?? PromotionRepository();

  static const Duration _cacheDuration = Duration(seconds: 25);
  static final Map<String, _CachedPromotion> _promotionCache = {};
  static final Map<String, Future<ProductPromotionInfo?>> _pendingRequests = {};

  final PromotionRepository _repository;

  static void clearCache() {
    _promotionCache.clear();
    _pendingRequests.clear();
  }

  Future<ProductPromotionInfo?> getActivePromotionForBusiness(
    String? businessUserId, {
    String? productId,
  }) async {
    final cleanBusinessUserId = businessUserId?.trim();
    if (cleanBusinessUserId == null || cleanBusinessUserId.isEmpty) {
      return null;
    }

    final cleanProductId = productId?.trim();
    final cacheKey = _cacheKey(cleanBusinessUserId, cleanProductId);
    final cachedPromotion = _promotionCache[cacheKey];
    if (cachedPromotion != null) {
      if (cachedPromotion.isFresh(_cacheDuration)) {
        return cachedPromotion.info;
      }
      _promotionCache.remove(cacheKey);
    }

    final pendingRequest = _pendingRequests[cacheKey];
    if (pendingRequest != null) return pendingRequest;

    final request = _loadPromotion(cleanBusinessUserId, cleanProductId);
    _pendingRequests[cacheKey] = request;

    try {
      return await request;
    } finally {
      _pendingRequests.remove(cacheKey);
    }
  }

  Future<ProductPromotionInfo?> _loadPromotion(
    String businessUserId,
    String? productId,
  ) async {
    final result = await _repository.getActivePromotionForBusiness(
      businessUserId,
      productId: productId,
    );

    final promotionInfo = result == null
        ? null
        : ProductPromotionInfo(
            promotion: result.promotion,
            coupon: result.coupon,
          );

    _promotionCache[_cacheKey(businessUserId, productId)] = _CachedPromotion(
      promotionInfo,
    );
    return promotionInfo;
  }

  static String _cacheKey(String businessUserId, String? productId) {
    final cleanProductId = productId?.trim();
    final productPart = cleanProductId == null || cleanProductId.isEmpty
        ? 'all'
        : cleanProductId;
    return '$businessUserId::$productPart';
  }
}

class _CachedPromotion {
  _CachedPromotion(this.info) : cachedAt = DateTime.now();

  final ProductPromotionInfo? info;
  final DateTime cachedAt;

  bool isFresh(Duration maxAge) => DateTime.now().difference(cachedAt) < maxAge;
}








