import 'package:intl/intl.dart';

import 'package:emprendedor/core/services/auth/user_session_service.dart';
import 'package:emprendedor/data/models/entrepreneur/stats/stats_model.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/order_controller.dart';
import 'package:emprendedor/features/entrepreneur/controllers/profile_controller.dart';
import 'package:emprendedor/features/entrepreneur/controllers/stats_controller.dart';

class EntrepreneurDashboardViewData {
  const EntrepreneurDashboardViewData({
    required this.statisticsOverview,
    required this.greetingText,
    required this.totalSalesAmount,
    required this.latestSaleDate,
    required this.todayOrders,
    required this.monthIncome,
    required this.dashboardError,
  });

  final StatisticsOverview statisticsOverview;
  final String greetingText;
  final double totalSalesAmount;
  final DateTime? latestSaleDate;
  final int todayOrders;
  final double monthIncome;
  final String? dashboardError;
}

class EntrepreneurHomeController {
  EntrepreneurHomeController({UserSessionService? sessionService})
    : _sessionService = sessionService ?? UserSessionService();

  final UserSessionService _sessionService;

  final DateFormat dateFormatter = DateFormat('dd MMM', 'es_ES');

  String formatCurrency(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  Future<void> loadDashboardData({
    required ProfileController profileController,
    required OrderController orderController,
    required StatsController statsController,
  }) async {
    final userId = _sessionService.currentUserId();
    if (userId == null) return;

    await _syncControllersWithUser(
      userId: userId,
      profileController: profileController,
      orderController: orderController,
      statsController: statsController,
    );
  }

  Future<void> refreshDashboard({
    required ProfileController profileController,
    required OrderController orderController,
    required StatsController statsController,
  }) async {
    await loadDashboardData(
      profileController: profileController,
      orderController: orderController,
      statsController: statsController,
    );

    await statsController.fetchStatistics();
  }

  EntrepreneurDashboardViewData buildViewData({
    required ProfileController profileController,
    required OrderController orderController,
    required StatsController statsController,
  }) {
    final statisticsOverview =
        statsController.statisticsOverview ?? StatisticsOverview.empty();

    final businessName = profileController.businessProfile?.name;
    final greetingText = businessName != null && businessName.trim().isNotEmpty
        ? 'Hola, $businessName'
        : 'Hola, Emprendedor';

    final paidDeliveredOrders = orderController.orders
        .where(
          (order) =>
              order.paymentStatus == PaymentStatus.paid && order.isDelivered,
        )
        .toList();

    final totalSalesAmount = paidDeliveredOrders.fold<double>(
      0,
      (sum, order) => sum + order.finalTotal,
    );

    final today = DateTime.now();
    final todayOrders = paidDeliveredOrders
        .where((order) => _isSameDay(_saleDate(order), today))
        .length;

    final monthIncome = paidDeliveredOrders
        .where((order) => _isSameMonth(_saleDate(order), today))
        .fold<double>(0, (sum, order) => sum + order.finalTotal);

    final latestSaleDate = paidDeliveredOrders.isEmpty
        ? null
        : paidDeliveredOrders
              .map(_saleDate)
              .reduce((a, b) => a.isAfter(b) ? a : b);

    final dashboardError =
        profileController.errorMessage ?? orderController.errorMessage;

    return EntrepreneurDashboardViewData(
      statisticsOverview: statisticsOverview,
      greetingText: greetingText,
      totalSalesAmount: totalSalesAmount,
      latestSaleDate: latestSaleDate,
      todayOrders: todayOrders,
      monthIncome: monthIncome,
      dashboardError: dashboardError,
    );
  }

  DateTime _saleDate(OrderModel order) {
    return order.deliveredAt?.toDate() ??
        order.updatedAt?.toDate() ??
        order.createdAt.toDate();
  }

  bool _isSameDay(DateTime date, DateTime reference) {
    return date.year == reference.year &&
        date.month == reference.month &&
        date.day == reference.day;
  }

  bool _isSameMonth(DateTime date, DateTime reference) {
    return date.year == reference.year && date.month == reference.month;
  }

  Future<void> _syncControllersWithUser({
    required String userId,
    required ProfileController profileController,
    required OrderController orderController,
    required StatsController statsController,
  }) {
    return Future.wait([
      profileController.setUserId(userId),
      orderController.setBusinessUserId(userId),
      statsController.setUserId(userId),
    ]);
  }
}








