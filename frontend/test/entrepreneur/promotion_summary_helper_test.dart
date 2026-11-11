import 'package:emprendedor/data/models/entrepreneur/promotions/promotion_model.dart';
import 'package:emprendedor/features/entrepreneur/helpers/promotion_summary_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PromotionModel promotion(PromotionStatus status) {
    final now = DateTime(2026, 1, 1);

    return PromotionModel.create(
      name: status.name,
      description: 'Promo de prueba',
      discountType: DiscountType.percentage,
      discountValue: 10,
      startDate: now,
      endDate: now.add(const Duration(days: 7)),
      userId: 'business-1',
      status: status,
    );
  }

  group('PromotionSummaryHelper', () {
    test('countByStatus counts promotions by status', () {
      final promotions = [
        promotion(PromotionStatus.active),
        promotion(PromotionStatus.active),
        promotion(PromotionStatus.scheduled),
        promotion(PromotionStatus.expired),
      ];

      expect(
        PromotionSummaryHelper.countByStatus(
          promotions,
          PromotionStatus.active,
        ),
        2,
      );
      expect(
        PromotionSummaryHelper.countByStatus(
          promotions,
          PromotionStatus.scheduled,
        ),
        1,
      );
      expect(
        PromotionSummaryHelper.countByStatus(
          promotions,
          PromotionStatus.expired,
        ),
        1,
      );
    });
  });
}
