import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentType { cash, online }

extension PaymentTypeX on PaymentType {
  String get value {
    switch (this) {
      case PaymentType.cash:
        return 'cash';
      case PaymentType.online:
        return 'online';
    }
  }

  String get label {
    switch (this) {
      case PaymentType.cash:
        return 'Efectivo';
      case PaymentType.online:
        return 'Pago en línea';
    }
  }
}

PaymentType stringToPaymentType(String? value) {
  switch (value) {
    case 'online':
    case 'stripe':
    case 'card':
      return PaymentType.online;

    case 'cash':
    case 'transfer':
    default:
      return PaymentType.cash;
  }
}

class PaymentMethodModel {
  final String? id;
  final PaymentType type;
  final Map<String, dynamic>? details;
  final String? userId;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  PaymentMethodModel({
    this.id,
    required this.type,
    this.details,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentMethodModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return PaymentMethodModel(
      id: doc.id,
      type: stringToPaymentType(data['type']?.toString()),
      details: data['details'] is Map
          ? Map<String, dynamic>.from(data['details'] as Map)
          : <String, dynamic>{},
      userId: data['userId']?.toString(),
      createdAt: data['createdAt'] is Timestamp ? data['createdAt'] : null,
      updatedAt: data['updatedAt'] is Timestamp ? data['updatedAt'] : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.value,
      'details': details ?? <String, dynamic>{},
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  PaymentMethodModel copyWith({
    String? id,
    PaymentType? type,
    Map<String, dynamic>? details,
    String? userId,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      type: type ?? this.type,
      details: details ?? this.details,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}








