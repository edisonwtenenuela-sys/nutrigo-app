import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/core/constants/app_constants.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/data/models/entrepreneur/stats/stats_model.dart';

class StatsRepository {
  final Logger _logger = Logger('StatsRepository');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<OrderModel>> watchRelevantOrders({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _firestore
        .collection(AppConstants.ordersCollection)
        .where('businessUserId', isEqualTo: userId)
        .limit(500)
        .snapshots()
        .map(
          (snapshot) => _parseRelevantOrders(
            snapshot.docs,
            startDate: startDate,
            endDate: endDate,
          ),
        );
  }

  Future<List<OrderModel>> getRelevantOrders({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.ordersCollection)
          .where('businessUserId', isEqualTo: userId)
          .limit(500)
          .get();

      return _parseRelevantOrders(
        snapshot.docs,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e, st) {
      _logger.severe('Error obteniendo pedidos para estadísticas', e, st);
      return [];
    }
  }

  Future<StatisticsOverview> calculateStatisticsOverview({
    required String userId,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
  }) async {
    final defaultStartDate =
        filterStartDate ?? DateTime.now().subtract(const Duration(days: 90));
    final defaultEndDate = filterEndDate ?? DateTime.now();

    final orders = await getRelevantOrders(
      userId: userId,
      startDate: defaultStartDate,
      endDate: defaultEndDate,
    );

    return buildStatisticsOverview(orders);
  }

  List<SalesDataPoint> _calculateDailySales(List<OrderModel> orders) {
    if (orders.isEmpty) return [];

    final salesByDay = groupBy<OrderModel, DateTime>(orders, (order) {
      final date = order.createdAt.toDate();
      return DateTime(date.year, date.month, date.day);
    });

    return salesByDay.entries
        .map((entry) {
          final dailyOrders = entry.value;

          final totalAmount = dailyOrders.sumByDouble(
            (order) => _safeMoney(order.totalPrice),
          );

          return SalesDataPoint(
            date: entry.key,
            salesAmount: totalAmount,
            orderCount: dailyOrders.length,
          );
        })
        .sorted((a, b) => a.date.compareTo(b.date));
  }

  List<SalesDataPoint> _calculateWeeklySales(List<OrderModel> orders) {
    if (orders.isEmpty) return [];

    final today = DateTime.now();
    final startOfWeek = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: today.weekday - 1));

    final result = <SalesDataPoint>[];

    for (int i = 0; i < 7; i++) {
      final currentDay = startOfWeek.add(Duration(days: i));

      final dayOrders = orders.where((order) {
        final date = order.createdAt.toDate();
        return date.year == currentDay.year &&
            date.month == currentDay.month &&
            date.day == currentDay.day;
      }).toList();

      final totalAmount = dayOrders.sumByDouble(
        (order) => _safeMoney(order.totalPrice),
      );

      result.add(
        SalesDataPoint(
          date: currentDay,
          salesAmount: totalAmount,
          orderCount: dayOrders.length,
        ),
      );
    }

    return result;
  }

  List<SalesDataPoint> _calculateMonthlySales(List<OrderModel> orders) {
    if (orders.isEmpty) return [];

    final salesByMonth = groupBy<OrderModel, String>(orders, (order) {
      return DateFormat('yyyy-MM', 'es_ES').format(order.createdAt.toDate());
    });

    return salesByMonth.entries
        .map((entry) {
          final monthlyOrders = entry.value;
          final totalAmount = monthlyOrders.sumByDouble(
            (order) => _safeMoney(order.totalPrice),
          );
          final date = DateTime.parse('${entry.key}-01');

          return SalesDataPoint(
            date: date,
            salesAmount: totalAmount,
            orderCount: monthlyOrders.length,
          );
        })
        .sorted((a, b) => a.date.compareTo(b.date));
  }

  List<TopProductStat> _calculateTopProducts(
    List<OrderModel> orders, {
    int limit = 5,
  }) {
    final productStats = <String, TopProductStat>{};

    for (final order in orders) {
      if (order.items.isEmpty) continue;

      for (final item in order.items) {
        if (item.productId.trim().isEmpty) continue;

        final quantity = item.quantity < 0 ? 0 : item.quantity;
        final price = _safeMoney(item.priceAtPurchase);
        final revenue = quantity * price;

        productStats.update(
          item.productId,
          (existing) => TopProductStat(
            productId: existing.productId,
            productName: existing.productName,
            productImageUrl: existing.productImageUrl,
            quantitySold: existing.quantitySold + quantity,
            totalRevenue: existing.totalRevenue + revenue,
          ),
          ifAbsent: () => TopProductStat(
            productId: item.productId,
            productName: item.productName,
            productImageUrl: item.imageUrl,
            quantitySold: quantity,
            totalRevenue: revenue,
          ),
        );
      }
    }

    final sortedProducts = productStats.values.toList()
      ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold));

    return sortedProducts.take(limit).toList();
  }

  List<FrequentCustomerStat> _calculateFrequentCustomers(
    List<OrderModel> orders, {
    int limit = 5,
  }) {
    final customerStats = <String, FrequentCustomerStat>{};

    for (final order in orders) {
      if (order.userId.trim().isEmpty) continue;

      final profileImageUrl = _cleanText(order.customerInfo.profileImageUrl);

      customerStats.update(
        order.userId,
        (existing) => FrequentCustomerStat(
          customerId: existing.customerId,
          customerName: existing.customerName,
          customerEmail: existing.customerEmail,
          profileImageUrl:
              _cleanText(existing.profileImageUrl) ?? profileImageUrl,
          totalOrders: existing.totalOrders + 1,
          totalSpent: existing.totalSpent + _safeMoney(order.totalPrice),
        ),
        ifAbsent: () => FrequentCustomerStat(
          customerId: order.userId,
          customerName: order.customerInfo.name.trim().isNotEmpty
              ? order.customerInfo.name
              : 'Cliente',
          customerEmail: order.customerInfo.email,
          profileImageUrl: profileImageUrl,
          totalOrders: 1,
          totalSpent: _safeMoney(order.totalPrice),
        ),
      );
    }

    final sortedCustomers = customerStats.values.toList()
      ..sort((a, b) => b.totalOrders.compareTo(a.totalOrders));

    return sortedCustomers.take(limit).toList();
  }

  StatisticsOverview buildStatisticsOverview(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return StatisticsOverview.empty();
    }

    return StatisticsOverview(
      dailySales: _calculateDailySales(orders),
      weeklySales: _calculateWeeklySales(orders),
      monthlySales: _calculateMonthlySales(orders),
      topProducts: _calculateTopProducts(orders, limit: 5),
      frequentCustomers: _calculateFrequentCustomers(orders, limit: 5),
      lastCalculated: Timestamp.now(),
    );
  }

  Map<int, int> calculatePeakSalesHours(List<OrderModel> orders) {
    final salesByHour = <int, int>{};
    for (final order in orders) {
      final hour = order.createdAt.toDate().hour;
      salesByHour[hour] = (salesByHour[hour] ?? 0) + 1;
    }
    return salesByHour;
  }

  List<OrderModel> _parseRelevantOrders(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final orders = <OrderModel>[];
    final adjustedEndDate = endDate == null
        ? null
        : DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    for (final doc in docs) {
      try {
        final order = OrderModel.fromFirestore(doc);
        final createdAt = order.createdAt.toDate();
        final isDelivered = order.status == OrderStatus.delivered;
        final isPaid = order.paymentStatus == PaymentStatus.paid;
        final isAfterStart =
            startDate == null || !createdAt.isBefore(startDate);
        final isBeforeEnd =
            adjustedEndDate == null || !createdAt.isAfter(adjustedEndDate);

        if (isDelivered && isPaid && isAfterStart && isBeforeEnd) {
          orders.add(order);
        }
      } catch (e, st) {
        _logger.warning(
          'Pedido ignorado en estadísticas por datos inválidos. ID: ${doc.id}',
          e,
          st,
        );
      }
    }

    return orders;
  }

  String? _cleanText(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  double _safeMoney(double value) {
    if (value.isNaN || value.isInfinite || value < 0) return 0.0;
    return value;
  }
}

extension SumByDouble<T> on Iterable<T> {
  double sumByDouble(double Function(T element) selector) {
    return fold(0.0, (previousValue, element) {
      return previousValue + selector(element);
    });
  }
}
