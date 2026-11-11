import 'package:emprendedor/data/models/shared/order_business_summary.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/data/repositories/shared/order_repository.dart';

class ClientOrderBusinessController {
  ClientOrderBusinessController({OrderRepository? repository})
    : _repository = repository ?? OrderRepository();

  final OrderRepository _repository;
  static final Map<String, OrderBusinessSummary> _summaryCache = {};

  OrderBusinessSummary? getCachedBusinessSummary(OrderModel order) {
    final businessId = order.businessUserId.trim();
    if (businessId.isEmpty) return null;
    return _summaryCache[businessId];
  }

  static void invalidateBusinessSummary(String businessUserId) {
    final businessId = businessUserId.trim();
    if (businessId.isEmpty) return;
    _summaryCache.remove(businessId);
  }

  static void cacheBusinessSummary(
    String businessUserId,
    OrderBusinessSummary summary,
  ) {
    final businessId = businessUserId.trim();
    if (businessId.isEmpty) return;
    if (summary.name.trim().isEmpty || summary.name == 'Emprendedor') return;
    _summaryCache[businessId] = summary;
  }

  Future<OrderBusinessSummary> getBusinessSummary(OrderModel order) async {
    final businessId = order.businessUserId.trim();
    if (businessId.isEmpty) return OrderBusinessSummary.fallback;

    final cached = _summaryCache[businessId];
    if (cached != null) return cached;

    final summary = await _repository.getBusinessSummaryForOrder(businessId);
    cacheBusinessSummary(businessId, summary);
    return summary;
  }

  Stream<OrderBusinessSummary> watchBusinessSummary(OrderModel order) {
    final businessId = order.businessUserId.trim();
    if (businessId.isEmpty) {
      return Stream.value(OrderBusinessSummary.fallback);
    }

    return _repository.watchBusinessSummaryForOrder(businessId).map((summary) {
      cacheBusinessSummary(businessId, summary);
      return summary;
    });
  }

  Future<void> preloadBusinessSummaries(List<OrderModel> orders) async {
    final uniqueOrders = <String, OrderModel>{};
    for (final order in orders) {
      final businessId = order.businessUserId.trim();
      if (businessId.isNotEmpty) uniqueOrders[businessId] = order;
    }

    await Future.wait(uniqueOrders.values.map(getBusinessSummary));
  }
}
