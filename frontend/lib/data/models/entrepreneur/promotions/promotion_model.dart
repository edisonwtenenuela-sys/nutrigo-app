import 'package:cloud_firestore/cloud_firestore.dart';

enum DiscountType { percentage, fixed }

enum PromotionStatus { active, scheduled, expired }

enum PromotionScope { all, product }

extension DiscountTypeExtension on DiscountType {
  String get displayName {
    switch (this) {
      case DiscountType.percentage:
        return 'Porcentaje';
      case DiscountType.fixed:
        return 'Valor fijo';
    }
  }
}

extension PromotionStatusExtension on PromotionStatus {
  String get displayName {
    switch (this) {
      case PromotionStatus.active:
        return 'Activa';
      case PromotionStatus.scheduled:
        return 'Programada';
      case PromotionStatus.expired:
        return 'Expirada';
    }
  }
}

extension PromotionScopeExtension on PromotionScope {
  String get displayName {
    switch (this) {
      case PromotionScope.all:
        return 'Todos los productos';
      case PromotionScope.product:
        return 'Productos seleccionados';
    }
  }
}

DiscountType stringToDiscountType(String? value) {
  switch (value) {
    case 'fixed':
      return DiscountType.fixed;
    case 'percentage':
    default:
      return DiscountType.percentage;
  }
}

PromotionStatus stringToPromotionStatus(String? value) {
  switch (value) {
    case 'active':
      return PromotionStatus.active;
    case 'expired':
      return PromotionStatus.expired;
    case 'scheduled':
    default:
      return PromotionStatus.scheduled;
  }
}

PromotionScope stringToPromotionScope(String? value) {
  switch (value) {
    case 'product':
      return PromotionScope.product;
    case 'all':
    default:
      return PromotionScope.all;
  }
}

class PromotionModel {
  final String? id;
  final String name;
  final String description;
  final DiscountType discountType;
  final double discountValue;
  final Timestamp startDate;
  final Timestamp endDate;
  final PromotionStatus status;
  final String userId;

  final PromotionScope scope;
  final List<String> productIds;

  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  PromotionModel({
    this.id,
    required this.name,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.userId,
    this.scope = PromotionScope.all,
    this.productIds = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory PromotionModel.create({
    String? id,
    required String name,
    required String description,
    required DiscountType discountType,
    required double discountValue,
    required DateTime startDate,
    required DateTime endDate,
    required String userId,
    PromotionStatus status = PromotionStatus.active,
    PromotionScope scope = PromotionScope.all,
    List<String> productIds = const [],
  }) {
    return PromotionModel(
      id: id,
      name: name,
      description: description,
      discountType: discountType,
      discountValue: discountValue,
      startDate: Timestamp.fromDate(startDate),
      endDate: Timestamp.fromDate(endDate),
      status: status,
      userId: userId,
      scope: scope,
      productIds: productIds,
    );
  }

  factory PromotionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return PromotionModel(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      discountType: stringToDiscountType(data['discountType']?.toString()),
      discountValue: (data['discountValue'] as num?)?.toDouble() ?? 0.0,
      startDate: data['startDate'] is Timestamp
          ? data['startDate'] as Timestamp
          : Timestamp.now(),
      endDate: data['endDate'] is Timestamp
          ? data['endDate'] as Timestamp
          : Timestamp.now(),
      status: stringToPromotionStatus(data['status']?.toString()),
      userId: data['userId']?.toString() ?? '',
      scope: stringToPromotionScope(data['scope']?.toString()),
      productIds: List<String>.from(data['productIds'] ?? []),
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
      'name': name,
      'description': description,
      'discountType': discountType.name,
      'discountValue': discountValue,
      'startDate': startDate,
      'endDate': endDate,
      'status': status.name,
      'userId': userId,
      'scope': scope.name,
      'productIds': productIds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  PromotionModel copyWith({
    String? id,
    String? name,
    String? description,
    DiscountType? discountType,
    double? discountValue,
    Timestamp? startDate,
    Timestamp? endDate,
    PromotionStatus? status,
    String? userId,
    PromotionScope? scope,
    List<String>? productIds,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return PromotionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      scope: scope ?? this.scope,
      productIds: productIds ?? this.productIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActiveNow {
    final now = DateTime.now();
    final start = startDate.toDate();
    final rawEnd = endDate.toDate();

    final end = DateTime(rawEnd.year, rawEnd.month, rawEnd.day, 23, 59, 59);

    return status == PromotionStatus.active &&
        !now.isBefore(start) &&
        !now.isAfter(end);
  }

  bool appliesToProduct(String? productId) {
    if (scope == PromotionScope.all) return true;

    if (productId == null || productId.trim().isEmpty) {
      return false;
    }

    return productIds.contains(productId);
  }
}








