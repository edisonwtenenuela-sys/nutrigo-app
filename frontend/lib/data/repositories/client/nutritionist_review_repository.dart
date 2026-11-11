import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/data/models/client/nutritionist_review_model.dart';

class NutritionistReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Map<String, String?> _clientImageCache = {};

  CollectionReference<Map<String, dynamic>> get _reviewsRef =>
      _firestore.collection('nutritionist_reviews');

  CollectionReference<Map<String, dynamic>> get _appointmentsRef =>
      _firestore.collection('appointments');

  CollectionReference<Map<String, dynamic>> get _nutritionistsRef =>
      _firestore.collection('nutritionists');

  CollectionReference<Map<String, dynamic>> get _clientsRef =>
      _firestore.collection('clients');

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  Stream<List<NutritionistReviewModel>> watchNutritionistReviews({
    required String nutritionistUserId,
    int? limit,
  }) {
    return _reviewsRef
        .where('nutritionistUserId', isEqualTo: nutritionistUserId)
        .snapshots()
        .asyncMap((snapshot) async {
          final reviews =
              snapshot.docs.map(NutritionistReviewModel.fromFirestore).toList()
                ..sort(
                  (a, b) =>
                      b.createdAt.toDate().compareTo(a.createdAt.toDate()),
                );

          final hydratedReviews = await _hydrateClientImages(reviews);

          if (limit == null || hydratedReviews.length <= limit) {
            return hydratedReviews;
          }
          return hydratedReviews.take(limit).toList();
        });
  }

  Future<List<NutritionistReviewModel>> _hydrateClientImages(
    List<NutritionistReviewModel> reviews,
  ) async {
    final missingClientIds = reviews
        .where(
          (review) =>
              _isBlank(review.clientProfileImageUrl) &&
              review.clientUserId.trim().isNotEmpty,
        )
        .map((review) => review.clientUserId.trim())
        .toSet();

    await Future.wait(
      missingClientIds.map((clientUserId) async {
        if (_clientImageCache.containsKey(clientUserId)) return;

        try {
          final clientDoc = await _clientsRef
              .doc(clientUserId)
              .get()
              .timeout(const Duration(seconds: 8));
          var imageUrl = clientDoc
              .data()?['profileImageUrl']
              ?.toString()
              .trim();

          if (_isBlank(imageUrl)) {
            final userDoc = await _usersRef
                .doc(clientUserId)
                .get()
                .timeout(const Duration(seconds: 8));
            imageUrl = userDoc.data()?['profileImageUrl']?.toString().trim();
          }

          _clientImageCache[clientUserId] = _isBlank(imageUrl)
              ? null
              : imageUrl;
        } catch (_) {
          _clientImageCache[clientUserId] = null;
        }
      }),
    );

    return reviews.map((review) {
      if (!_isBlank(review.clientProfileImageUrl)) return review;

      final imageUrl = _clientImageCache[review.clientUserId.trim()];
      if (_isBlank(imageUrl)) return review;

      return review.copyWith(clientProfileImageUrl: imageUrl);
    }).toList();
  }

  bool _isBlank(String? value) => value == null || value.trim().isEmpty;

  Future<void> submitReview({
    required AppointmentModel appointment,
    required int rating,
    String? comment,
  }) async {
    if (appointment.id == null) {
      throw Exception('La cita no tiene ID.');
    }

    if (!appointment.canClientReview) {
      throw Exception('Esta cita no puede ser valorada.');
    }

    final review = NutritionistReviewModel(
      appointmentId: appointment.id!,
      clientUserId: appointment.clientUserId,
      clientName: appointment.clientName,
      clientProfileImageUrl: appointment.clientProfileImageUrl,
      nutritionistUserId: appointment.nutritionistUserId,
      nutritionistName: appointment.nutritionistName,
      rating: rating,
      comment: comment?.trim().isEmpty == true ? null : comment?.trim(),
      createdAt: Timestamp.now(),
    );

    final batch = _firestore.batch();

    final reviewRef = _reviewsRef.doc(appointment.id);
    final appointmentRef = _appointmentsRef.doc(appointment.id);
    final nutritionistRef = _nutritionistsRef.doc(
      appointment.nutritionistUserId,
    );

    final appointmentDoc = await appointmentRef
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));

    if (!appointmentDoc.exists) {
      throw Exception('La cita ya no está disponible.');
    }

    batch.set(reviewRef, review.toMap());

    batch.update(appointmentRef, {
      'isReviewed': true,
      'reviewRating': rating,
      'reviewComment': review.comment,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(nutritionistRef, {
      'reviewsCount': FieldValue.increment(1),
      'reviewsSum': FieldValue.increment(rating),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit().timeout(const Duration(seconds: 12));
  }
}
