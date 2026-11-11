import 'package:flutter_test/flutter_test.dart';

import 'package:emprendedor/data/models/client/business_review_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/business_reviews_controller.dart';

void main() {
  BusinessReviewModel review({required double rating, String comment = ''}) {
    return BusinessReviewModel(
      orderId: 'order-1',
      businessUserId: 'business-1',
      clientUserId: 'client-1',
      rating: rating,
      comment: comment,
    );
  }

  group('BusinessReviewsController pure helpers', () {
    test('detects empty and non-empty review lists', () {
      expect(BusinessReviewsController.hasReviewItems([]), isFalse);
      expect(
        BusinessReviewsController.hasReviewItems([review(rating: 5)]),
        isTrue,
      );
    });

    test('calculates average rating safely', () {
      expect(BusinessReviewsController.calculateAverageRating([]), 0);
      expect(
        BusinessReviewsController.calculateAverageRating([
          review(rating: 5),
          review(rating: 4),
          review(rating: 3),
        ]),
        4,
      );
    });

    test('uses fallback text when review comment is blank', () {
      expect(
        BusinessReviewsController.resolveCommentText(review(rating: 5)),
        'Sin comentario.',
      );
      expect(
        BusinessReviewsController.resolveCommentText(
          review(rating: 5, comment: 'Muy buena experiencia.'),
        ),
        'Muy buena experiencia.',
      );
    });
  });
}
