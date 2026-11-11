import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:emprendedor/data/models/client/business_review_model.dart';

class BusinessReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Map<String, String?> _orderClientImageCache = {};
  static final Map<String, List<BusinessReviewModel>> _businessReviewsCache =
      {};

  CollectionReference<Map<String, dynamic>> get _reviewsRef {
    return _firestore.collection('business_reviews');
  }

  CollectionReference<Map<String, dynamic>> get _businessProfilesRef {
    return _firestore.collection('business_profiles');
  }

  CollectionReference<Map<String, dynamic>> get _ordersRef {
    return _firestore.collection('orders');
  }

  Stream<List<BusinessReviewModel>> watchBusinessReviews({
    required String businessUserId,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _reviewsRef
        .where('businessUserId', isEqualTo: businessUserId)
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().asyncMap((snapshot) async {
      final reviews = snapshot.docs
          .map(BusinessReviewModel.fromFirestore)
          .toList();
      final hydratedReviews = await _hydrateClientImages(reviews);
      _businessReviewsCache[businessUserId] = hydratedReviews;
      return hydratedReviews;
    });
  }

  List<BusinessReviewModel>? cachedBusinessReviews(String businessUserId) {
    final cachedReviews = _businessReviewsCache[businessUserId];
    if (cachedReviews == null || cachedReviews.isEmpty) return null;
    return List<BusinessReviewModel>.unmodifiable(cachedReviews);
  }

  Future<List<BusinessReviewModel>> _hydrateClientImages(
    List<BusinessReviewModel> reviews,
  ) async {
    final missingIds = reviews
        .where(
          (review) =>
              _isBlank(review.clientProfileImageUrl) &&
              review.orderId.trim().isNotEmpty,
        )
        .map((review) => review.orderId.trim())
        .toSet();

    await Future.wait(
      missingIds.map((orderId) async {
        if (_orderClientImageCache.containsKey(orderId)) return;

        try {
          final doc = await _ordersRef.doc(orderId).get();
          final customerInfo = doc.data()?['customerInfo'] as Map?;
          final imageUrl = customerInfo?['profileImageUrl']?.toString().trim();
          _orderClientImageCache[orderId] = _isBlank(imageUrl)
              ? null
              : imageUrl;
        } catch (_) {
          _orderClientImageCache[orderId] = null;
        }
      }),
    );

    return reviews.map((review) {
      if (!_isBlank(review.clientProfileImageUrl)) return review;

      final imageUrl = _orderClientImageCache[review.orderId.trim()];
      if (_isBlank(imageUrl)) return review;

      return review.copyWith(clientProfileImageUrl: imageUrl);
    }).toList();
  }

  bool _isBlank(String? value) => value == null || value.trim().isEmpty;

  Future<bool> hasReviewedOrder({
    required String orderId,
    required String clientUserId,
  }) async {
    final snapshot = await _reviewsRef
        .where('orderId', isEqualTo: orderId)
        .where('clientUserId', isEqualTo: clientUserId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> addReview(BusinessReviewModel review) async {
    final alreadyReviewed = await hasReviewedOrder(
      orderId: review.orderId,
      clientUserId: review.clientUserId,
    );

    if (alreadyReviewed) {
      throw Exception('Ya calificaste este pedido.');
    }

    final businessDocRef = _businessProfilesRef.doc(review.businessUserId);

    await _firestore.runTransaction((transaction) async {
      final reviewDocRef = _reviewsRef.doc();

      final businessSnapshot = await transaction.get(businessDocRef);

      transaction.set(reviewDocRef, review.toFirestore());

      if (!businessSnapshot.exists) {
        return;
      }

      final data = businessSnapshot.data() ?? {};

      final currentRating = (data['rating'] as num?)?.toDouble() ?? 0.0;

      final currentTotalReviews = (data['totalReviews'] as num?)?.toInt() ?? 0;

      final newTotalReviews = currentTotalReviews + 1;

      final newRating = currentTotalReviews == 0
          ? review.rating.toDouble()
          : ((currentRating * currentTotalReviews) + review.rating) /
                newTotalReviews;

      transaction.update(businessDocRef, {
        'rating': double.parse(newRating.toStringAsFixed(2)),
        'totalReviews': newTotalReviews,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
