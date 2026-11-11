import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';
import 'package:emprendedor/data/models/entrepreneur/index.dart';

import 'package:emprendedor/core/constants/app_constants.dart';

class PromotionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger('PromotionRepository');

  // ==========================
  // PROMOCIONES
  // ==========================
  Stream<List<PromotionModel>> getPromotions(String userId) {
    return _firestore
        .collection(AppConstants.promotionsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PromotionModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<ActivePromotionResult?> getActivePromotionForBusiness(
    String businessUserId, {
    String? productId,
  }) async {
    if (businessUserId.trim().isEmpty) return null;

    final promoSnapshot = await _firestore
        .collection(AppConstants.promotionsCollection)
        .where('userId', isEqualTo: businessUserId)
        .where('status', isEqualTo: PromotionStatus.active.name)
        .limit(20)
        .get()
        .timeout(const Duration(seconds: 10));

    PromotionModel? activePromotion;
    String? activePromotionId;

    for (final doc in promoSnapshot.docs) {
      final promotion = PromotionModel.fromFirestore(doc);

      if (promotion.isActiveNow && promotion.appliesToProduct(productId)) {
        activePromotion = promotion;
        activePromotionId = doc.id;
        break;
      }
    }

    if (activePromotion == null || activePromotionId == null) return null;

    CouponModel? coupon;
    final couponSnapshot = await _firestore
        .collection(AppConstants.promotionsCollection)
        .doc(activePromotionId)
        .collection(AppConstants.couponsSubcollection)
        .where('status', isEqualTo: CouponStatus.active.name)
        .where('isUsed', isEqualTo: false)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 10));

    if (couponSnapshot.docs.isNotEmpty) {
      coupon = CouponModel.fromFirestore(couponSnapshot.docs.first);
    }

    return ActivePromotionResult(promotion: activePromotion, coupon: coupon);
  }

  Future<void> createPromotion(PromotionModel promotion, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 10));

      final promo = promotion.copyWith(userId: userId);
      await _firestore
          .collection(AppConstants.promotionsCollection)
          .add(promo.toFirestore())
          .timeout(const Duration(seconds: 12));

      _logger.info('Promoción creada: ${promotion.name}');
    } catch (e, st) {
      _logger.severe('Error creando promoción', e, st);
      rethrow;
    }
  }

  Future<void> updatePromotion(PromotionModel promotion, String userId) async {
    if (promotion.id == null) {
      throw Exception('ID requerido para actualizar promoción');
    }

    final docRef = _firestore
        .collection(AppConstants.promotionsCollection)
        .doc(promotion.id);

    final doc = await docRef
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));

    if (!doc.exists || doc.data()?['userId'] != userId) {
      throw Exception("No autorizado.");
    }

    await docRef
        .set(
          promotion.copyWith(userId: userId).toFirestore(),
          SetOptions(merge: true),
        )
        .timeout(const Duration(seconds: 12));
  }

  Future<void> deletePromotion(String promotionId, String userId) async {
    final docRef = _firestore
        .collection(AppConstants.promotionsCollection)
        .doc(promotionId);

    final doc = await docRef
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));

    if (!doc.exists || doc.data()?['userId'] != userId) {
      throw Exception("No autorizado.");
    }

    await docRef.delete().timeout(const Duration(seconds: 12));
  }

  // ==========================
  // CUPONES
  // ==========================
  Stream<List<CouponModel>> getCouponsForPromotion(
    String promotionId,
    String userId,
  ) {
    if (promotionId.trim().isEmpty || userId.trim().isEmpty) {
      return const Stream.empty();
    }

    return _firestore
        .collection(AppConstants.promotionsCollection)
        .doc(promotionId)
        .collection(AppConstants.couponsSubcollection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CouponModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> createCoupon(CouponModel coupon, String userId) async {
    final promoDoc = await _firestore
        .collection(AppConstants.promotionsCollection)
        .doc(coupon.promotionId)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));

    if (!promoDoc.exists || promoDoc.data()?['userId'] != userId) {
      throw Exception("No autorizado.");
    }

    await _firestore
        .collection(AppConstants.promotionsCollection)
        .doc(coupon.promotionId)
        .collection(AppConstants.couponsSubcollection)
        .add(coupon.toFirestore())
        .timeout(const Duration(seconds: 12));
  }

  Future<void> updateCoupon(CouponModel coupon, String userId) async {
    if (coupon.id == null) {
      throw Exception('ID requerido para actualizar cupón');
    }

    final promoDoc = await _firestore
        .collection(AppConstants.promotionsCollection)
        .doc(coupon.promotionId)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));

    if (!promoDoc.exists || promoDoc.data()?['userId'] != userId) {
      throw Exception("No autorizado.");
    }

    await _firestore
        .collection(AppConstants.promotionsCollection)
        .doc(coupon.promotionId)
        .collection(AppConstants.couponsSubcollection)
        .doc(coupon.id)
        .set(coupon.toFirestore(), SetOptions(merge: true))
        .timeout(const Duration(seconds: 12));
  }

  Future<void> deleteCoupon(
    String promotionId,
    String couponId,
    String userId,
  ) async {
    final promoDoc = await _firestore
        .collection(AppConstants.promotionsCollection)
        .doc(promotionId)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));

    if (!promoDoc.exists || promoDoc.data()?['userId'] != userId) {
      throw Exception("No autorizado.");
    }

    await _firestore
        .collection(AppConstants.promotionsCollection)
        .doc(promotionId)
        .collection(AppConstants.couponsSubcollection)
        .doc(couponId)
        .delete()
        .timeout(const Duration(seconds: 12));
  }
}

class ActivePromotionResult {
  const ActivePromotionResult({required this.promotion, this.coupon});

  final PromotionModel promotion;
  final CouponModel? coupon;
}
