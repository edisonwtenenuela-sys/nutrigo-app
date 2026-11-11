import 'package:cloud_firestore/cloud_firestore.dart';

enum CouponStatus { active, expired, used, disabled }

CouponStatus stringToCouponStatus(String? value) {
  switch (value?.toLowerCase()) {
    case 'expired':
      return CouponStatus.expired;
    case 'used':
      return CouponStatus.used;
    case 'disabled':
      return CouponStatus.disabled;
    case 'active':
    default:
      return CouponStatus.active;
  }
}

class CouponModel {
  final String? id;
  final String code;
  final String promotionId;

  final double discountValue;
  final double minimumPurchase;

  final Timestamp validityDate;
  final CouponStatus status;

  final bool isUsed;
  final String? usedByUserId;
  final String? usedInOrderId;
  final Timestamp? usedAt;

  final String? userId;

  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  CouponModel({
    this.id,
    required this.code,
    required this.promotionId,
    required this.discountValue,
    required this.validityDate,
    this.minimumPurchase = 0.0,
    this.status = CouponStatus.active,
    this.isUsed = false,
    this.usedByUserId,
    this.usedInOrderId,
    this.usedAt,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory CouponModel.create({
    required String code,
    required String promotionId,
    required double discountValue,
    required DateTime validityDate,
    double minimumPurchase = 0.0,
    String? userId,
  }) {
    return CouponModel(
      code: code,
      promotionId: promotionId,
      discountValue: discountValue,
      validityDate: Timestamp.fromDate(validityDate),
      minimumPurchase: minimumPurchase,
      status: CouponStatus.active,
      isUsed: false,
      userId: userId,
    );
  }

  factory CouponModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return CouponModel(
      id: doc.id,
      code: data['code']?.toString() ?? '',
      promotionId: data['promotionId']?.toString() ?? '',
      discountValue: (data['discountValue'] as num?)?.toDouble() ?? 0.0,
      minimumPurchase: (data['minimumPurchase'] as num?)?.toDouble() ?? 0.0,
      validityDate: data['validityDate'] is Timestamp
          ? data['validityDate'] as Timestamp
          : Timestamp.now(),
      status: stringToCouponStatus(data['status']?.toString()),
      isUsed: data['isUsed'] as bool? ?? false,
      usedByUserId: data['usedByUserId']?.toString(),
      usedInOrderId: data['usedInOrderId']?.toString(),
      usedAt: data['usedAt'] is Timestamp ? data['usedAt'] as Timestamp : null,
      userId: data['userId']?.toString(),
      createdAt: data['createdAt'] is Timestamp
          ? data['createdAt'] as Timestamp
          : null,
      updatedAt: data['updatedAt'] is Timestamp
          ? data['updatedAt'] as Timestamp
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'promotionId': promotionId,
      'discountValue': discountValue,
      'minimumPurchase': minimumPurchase,
      'validityDate': validityDate,
      'status': status.name,
      'isUsed': isUsed,
      'usedByUserId': usedByUserId,
      'usedInOrderId': usedInOrderId,
      'usedAt': usedAt,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  CouponModel copyWith({
    String? id,
    String? code,
    String? promotionId,
    double? discountValue,
    double? minimumPurchase,
    Timestamp? validityDate,
    CouponStatus? status,
    bool? isUsed,
    String? usedByUserId,
    String? usedInOrderId,
    Timestamp? usedAt,
    String? userId,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return CouponModel(
      id: id ?? this.id,
      code: code ?? this.code,
      promotionId: promotionId ?? this.promotionId,
      discountValue: discountValue ?? this.discountValue,
      minimumPurchase: minimumPurchase ?? this.minimumPurchase,
      validityDate: validityDate ?? this.validityDate,
      status: status ?? this.status,
      isUsed: isUsed ?? this.isUsed,
      usedByUserId: usedByUserId ?? this.usedByUserId,
      usedInOrderId: usedInOrderId ?? this.usedInOrderId,
      usedAt: usedAt ?? this.usedAt,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isExpired {
    final now = DateTime.now();
    final rawDate = validityDate.toDate();

    final endDate = DateTime(
      rawDate.year,
      rawDate.month,
      rawDate.day,
      23,
      59,
      59,
    );

    return now.isAfter(endDate);
  }

  bool get canBeUsed {
    return status == CouponStatus.active && !isUsed && !isExpired;
  }
}








