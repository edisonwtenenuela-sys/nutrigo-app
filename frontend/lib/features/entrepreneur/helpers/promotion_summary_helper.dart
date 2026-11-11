import 'package:emprendedor/data/models/entrepreneur/promotions/promotion_model.dart';

class PromotionSummaryHelper {
  const PromotionSummaryHelper._();

  static int countByStatus(
    List<PromotionModel> promotions,
    PromotionStatus status,
  ) {
    return promotions.where((item) => item.status == status).length;
  }
}








