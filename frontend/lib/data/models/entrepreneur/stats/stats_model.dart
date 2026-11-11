import 'package:cloud_firestore/cloud_firestore.dart';

enum SalesInterval { daily, weekly, monthly }

class SalesDataPoint {
  final DateTime date;
  final double salesAmount;
  final int orderCount;

  SalesDataPoint({
    required this.date,
    required this.salesAmount,
    required this.orderCount,
  });

  factory SalesDataPoint.fromMap(Map<String, dynamic> data) {
    return SalesDataPoint(
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      salesAmount: (data['salesAmount'] as num?)?.toDouble() ?? 0.0,
      orderCount: (data['orderCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'salesAmount': salesAmount,
      'orderCount': orderCount,
    };
  }
}

class TopProductStat {
  final String productId;
  final String productName;
  final String? productImageUrl;
  final int quantitySold;
  final double totalRevenue;

  TopProductStat({
    required this.productId,
    required this.productName,
    this.productImageUrl,
    required this.quantitySold,
    required this.totalRevenue,
  });

  factory TopProductStat.fromMap(Map<String, dynamic> data) {
    return TopProductStat(
      productId: data['productId']?.toString() ?? '',
      productName: data['productName']?.toString() ?? '',
      productImageUrl: data['productImageUrl']?.toString(),
      quantitySold: (data['quantitySold'] as num?)?.toInt() ?? 0,
      totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'quantitySold': quantitySold,
      'totalRevenue': totalRevenue,
    };
  }
}

class FrequentCustomerStat {
  final String customerId;
  final String customerName;
  final String? customerEmail;
  final String? profileImageUrl;
  final int totalOrders;
  final double totalSpent;

  FrequentCustomerStat({
    required this.customerId,
    required this.customerName,
    this.customerEmail,
    this.profileImageUrl,
    required this.totalOrders,
    required this.totalSpent,
  });

  factory FrequentCustomerStat.fromMap(Map<String, dynamic> data) {
    return FrequentCustomerStat(
      customerId: data['customerId']?.toString() ?? '',
      customerName: data['customerName']?.toString() ?? '',
      customerEmail: data['customerEmail']?.toString(),
      profileImageUrl: data['profileImageUrl']?.toString(),
      totalOrders: (data['totalOrders'] as num?)?.toInt() ?? 0,
      totalSpent: (data['totalSpent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'profileImageUrl': profileImageUrl,
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
    };
  }
}

class StatisticsOverview {
  final List<SalesDataPoint> dailySales;
  final List<SalesDataPoint> weeklySales;
  final List<SalesDataPoint> monthlySales;
  final List<TopProductStat> topProducts;
  final List<FrequentCustomerStat> frequentCustomers;
  final Timestamp lastCalculated;

  StatisticsOverview({
    required this.dailySales,
    required this.weeklySales,
    required this.monthlySales,
    required this.topProducts,
    required this.frequentCustomers,
    required this.lastCalculated,
  });

  factory StatisticsOverview.empty() {
    return StatisticsOverview(
      dailySales: [],
      weeklySales: [],
      monthlySales: [],
      topProducts: [],
      frequentCustomers: [],
      lastCalculated: Timestamp.now(),
    );
  }

  factory StatisticsOverview.fromMap(Map<String, dynamic> data) {
    return StatisticsOverview(
      dailySales: (data['dailySales'] as List<dynamic>? ?? [])
          .map((e) => SalesDataPoint.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      weeklySales: (data['weeklySales'] as List<dynamic>? ?? [])
          .map((e) => SalesDataPoint.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      monthlySales: (data['monthlySales'] as List<dynamic>? ?? [])
          .map((e) => SalesDataPoint.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      topProducts: (data['topProducts'] as List<dynamic>? ?? [])
          .map((e) => TopProductStat.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      frequentCustomers: (data['frequentCustomers'] as List<dynamic>? ?? [])
          .map(
            (e) => FrequentCustomerStat.fromMap(Map<String, dynamic>.from(e)),
          )
          .toList(),
      lastCalculated: data['lastCalculated'] is Timestamp
          ? data['lastCalculated'] as Timestamp
          : Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dailySales': dailySales.map((e) => e.toMap()).toList(),
      'weeklySales': weeklySales.map((e) => e.toMap()).toList(),
      'monthlySales': monthlySales.map((e) => e.toMap()).toList(),
      'topProducts': topProducts.map((e) => e.toMap()).toList(),
      'frequentCustomers': frequentCustomers.map((e) => e.toMap()).toList(),
      'lastCalculated': lastCalculated,
    };
  }
}








