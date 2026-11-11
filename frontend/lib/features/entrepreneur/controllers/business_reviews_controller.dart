import 'package:emprendedor/data/models/client/business_review_model.dart';
import 'package:emprendedor/data/repositories/client/business_review_repository.dart';

class BusinessReviewsController {
  BusinessReviewsController({BusinessReviewRepository? repository})
    : _repository = repository ?? BusinessReviewRepository();

  final BusinessReviewRepository _repository;

  Stream<List<BusinessReviewModel>> watchReviews(
    String businessUserId, {
    int? limit,
  }) {
    return _repository.watchBusinessReviews(
      businessUserId: businessUserId,
      limit: limit,
    );
  }

  List<BusinessReviewModel>? cachedReviews(String businessUserId) {
    return _repository.cachedBusinessReviews(businessUserId);
  }

  bool hasReviews(List<BusinessReviewModel> reviews) => hasReviewItems(reviews);

  double averageRating(List<BusinessReviewModel> reviews) {
    return calculateAverageRating(reviews);
  }

  List<BusinessReviewModel> uniqueRecentReviewsByClient(
    List<BusinessReviewModel> reviews, {
    int limit = 3,
  }) {
    return selectUniqueRecentReviewsByClient(reviews, limit: limit);
  }

  String commentText(BusinessReviewModel review) {
    return resolveCommentText(review);
  }

  String clientNameText(BusinessReviewModel review) {
    return resolveClientName(review);
  }

  static bool hasReviewItems(List<BusinessReviewModel> reviews) {
    return reviews.isNotEmpty;
  }

  static double calculateAverageRating(List<BusinessReviewModel> reviews) {
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }

  static List<BusinessReviewModel> selectUniqueRecentReviewsByClient(
    List<BusinessReviewModel> reviews, {
    int limit = 3,
  }) {
    final selected = <BusinessReviewModel>[];
    final seenClientIds = <String>{};

    for (final review in reviews) {
      final clientKey = review.clientUserId.trim().isNotEmpty
          ? review.clientUserId.trim()
          : review.clientName.trim().toLowerCase();

      if (clientKey.isNotEmpty && seenClientIds.contains(clientKey)) {
        continue;
      }

      selected.add(review);
      if (clientKey.isNotEmpty) seenClientIds.add(clientKey);
      if (selected.length >= limit) break;
    }

    return selected;
  }

  static String resolveCommentText(BusinessReviewModel review) {
    return review.comment.trim().isEmpty ? 'Sin comentario.' : review.comment;
  }

  static String resolveClientName(BusinessReviewModel review) {
    final name = review.clientName.trim();
    return name.isEmpty ? 'Cliente' : name;
  }
}
