import 'package:cloud_firestore/cloud_firestore.dart';

class NutritionistVerificationRequestModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String specialty;
  final String professionalDescription;
  final String licenseNumber;
  final String professionalRegistryType;
  final String status;
  final String? message;
  final DateTime createdAt;

  NutritionistVerificationRequestModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialty,
    required this.professionalDescription,
    required this.licenseNumber,
    required this.professionalRegistryType,
    required this.status,
    this.message,
    required this.createdAt,
  });

  factory NutritionistVerificationRequestModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return NutritionistVerificationRequestModel(
      id: id,
      userId: map['userId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      specialty: map['specialty']?.toString() ?? '',
      professionalDescription: map['professionalDescription']?.toString() ?? '',
      licenseNumber:
          map['professionalLicense']?.toString() ??
          map['licenseNumber']?.toString() ??
          '',
      professionalRegistryType:
          map['professionalRegistryType']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending',
      message: map['message']?.toString(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'specialty': specialty,
      'professionalDescription': professionalDescription,
      'professionalLicense': licenseNumber,
      'licenseNumber': licenseNumber,
      'professionalRegistryType': professionalRegistryType,
      'status': status,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}








