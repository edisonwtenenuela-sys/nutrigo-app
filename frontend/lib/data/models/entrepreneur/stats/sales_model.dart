import 'package:cloud_firestore/cloud_firestore.dart';

class SalesModel {
  final String? id;
  final String orderId;
  final String productId;
  final String productName;

  final String businessUserId;
  final String? customerId;
  final String? customerName;

  final int quantity;
  final double unitPrice;
  final double totalAmount;

  final Timestamp saleDate;
  final Timestamp? createdAt;

  SalesModel({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.businessUserId,
    this.customerId,
    this.customerName,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.saleDate,
    this.createdAt,
  });

  factory SalesModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final quantity = (data['quantity'] as num?)?.toInt() ?? 0;
    final unitPrice = (data['unitPrice'] as num?)?.toDouble() ?? 0.0;

    return SalesModel(
      id: doc.id,
      orderId: data['orderId']?.toString() ?? '',
      productId: data['productId']?.toString() ?? '',
      productName: data['productName']?.toString() ?? '',
      businessUserId: data['businessUserId']?.toString() ?? '',
      customerId: data['customerId']?.toString(),
      customerName: data['customerName']?.toString(),
      quantity: quantity,
      unitPrice: unitPrice,
      totalAmount:
          (data['totalAmount'] as num?)?.toDouble() ?? (quantity * unitPrice),
      saleDate: data['saleDate'] is Timestamp
          ? data['saleDate'] as Timestamp
          : Timestamp.now(),
      createdAt: data['createdAt'] is Timestamp
          ? data['createdAt'] as Timestamp
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'businessUserId': businessUserId,
      'customerId': customerId,
      'customerName': customerName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalAmount': totalAmount,
      'saleDate': saleDate,
      'createdAt': createdAt,
    };
  }

  SalesModel copyWith({
    String? id,
    String? orderId,
    String? productId,
    String? productName,
    String? businessUserId,
    String? customerId,
    String? customerName,
    int? quantity,
    double? unitPrice,
    double? totalAmount,
    Timestamp? saleDate,
    Timestamp? createdAt,
  }) {
    return SalesModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      businessUserId: businessUserId ?? this.businessUserId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      saleDate: saleDate ?? this.saleDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}








