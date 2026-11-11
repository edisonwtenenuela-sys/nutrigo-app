import 'package:emprendedor/data/models/shared/order_model.dart';

class ClientOrdersOverviewHelper {
  static int countByStatus(List<OrderModel> orders, OrderStatus status) {
    return orders.where((order) => order.status == status).length;
  }

  static int activeCount(List<OrderModel> orders) {
    return orders
        .where(
          (order) =>
      order.status != OrderStatus.delivered &&
          order.status != OrderStatus.cancelled,
    )
        .length;
  }

  static double totalSpent(List<OrderModel> orders) {
    return orders
        .where((order) => order.status != OrderStatus.cancelled)
        .fold(0.0, (total, order) => total + order.finalTotal);
  }
}