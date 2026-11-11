import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';
import 'package:emprendedor/data/models/shared/order_business_summary.dart';
import 'package:emprendedor/data/repositories/shared/order_repository.dart';
import 'package:emprendedor/features/client/controllers/client_product_promotion_controller.dart';

class ClientProductCardController {
  ClientProductCardController({
    OrderRepository? orderRepository,
    ClientProductPromotionController? promotionController,
  }) : _orderRepository = orderRepository ?? OrderRepository(),
       _promotionController =
           promotionController ?? ClientProductPromotionController();

  final OrderRepository _orderRepository;
  final ClientProductPromotionController _promotionController;
  static final Map<String, OrderBusinessSummary> _businessSummaryCache = {};

  static bool isGenericBusinessName(String name) {
    const genericNames = {
      'Emprendedor',
      'Emprendimiento',
      'Nuevo emprendimiento',
    };

    return genericNames.contains(name.trim());
  }

  static void cacheBusinessSummary(
    String userId,
    OrderBusinessSummary summary,
  ) {
    final cleanUserId = userId.trim();
    if (cleanUserId.isEmpty || isGenericBusinessName(summary.name)) return;
    _businessSummaryCache[cleanUserId] = summary;
  }

  static void invalidateBusinessSummary(String userId) {
    final cleanUserId = userId.trim();
    if (cleanUserId.isEmpty) return;
    _businessSummaryCache.remove(cleanUserId);
  }

  static OrderBusinessSummary? cachedBusinessSummary(String userId) {
    final cleanUserId = userId.trim();
    if (cleanUserId.isEmpty) return null;
    return _businessSummaryCache[cleanUserId];
  }

  Future<OrderBusinessSummary?> getBusinessSummaryForProduct(
    ProductModel product,
  ) async {
    final userId = product.userId?.trim();
    if (userId == null || userId.isEmpty) return null;

    final cachedSummary = _businessSummaryCache[userId];
    if (cachedSummary != null) return cachedSummary;

    final summary = await _orderRepository.getBusinessSummaryForOrder(userId);
    cacheBusinessSummary(userId, summary);
    return summary;
  }

  Stream<OrderBusinessSummary?> watchBusinessSummaryForProduct(
    ProductModel product,
  ) {
    final userId = product.userId?.trim();
    if (userId == null || userId.isEmpty) {
      return Stream.value(null);
    }

    return _orderRepository.watchBusinessSummaryForOrder(userId).map((summary) {
      cacheBusinessSummary(userId, summary);
      return summary;
    });
  }

  Future<ProductPromotionInfo?> getPromotionForProduct(ProductModel product) {
    return _promotionController.getActivePromotionForBusiness(
      product.userId,
      productId: product.id,
    );
  }
}
