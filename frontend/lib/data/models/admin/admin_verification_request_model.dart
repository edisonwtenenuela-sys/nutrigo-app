import 'package:cloud_firestore/cloud_firestore.dart';

class AdminVerificationRequestModel {
  final String id;
  final String userId;
  final String businessName;
  final String ownerName;
  final String email;
  final String phone;
  final String address;
  final String documentType;
  final String documentNumber;
  final String status;
  final String? message;
  final DateTime createdAt;

  AdminVerificationRequestModel({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.address,
    this.documentType = '',
    this.documentNumber = '',
    required this.status,
    this.message,
    required this.createdAt,
  });

  factory AdminVerificationRequestModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return AdminVerificationRequestModel(
      id: id,
      userId: map['userId'] ?? '',
      businessName: map['businessName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      documentType: map['documentType'] ?? '',
      documentNumber: map['documentNumber'] ?? '',
      status: map['status'] ?? 'pending',
      message: map['message'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'businessName': businessName,
      'ownerName': ownerName,
      'email': email,
      'phone': phone,
      'address': address,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'status': status,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}








