import 'package:cloud_firestore/cloud_firestore.dart';

/// Clase base con los campos comunes a todos los perfiles de usuario.
/// ClientProfileModel, BusinessProfileModel y NutritionistProfileModel
/// pueden extender esta clase para evitar repetición.
abstract class BaseUserProfileModel {
  final String? id;
  final String userId;
  final String name;
  final String role;
  final String? email;
  final String? phone;
  final String? profileImageUrl;
  final bool isActive;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const BaseUserProfileModel({
    this.id,
    required this.userId,
    required this.name,
    required this.role,
    this.email,
    this.phone,
    this.profileImageUrl,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Mapa con los campos base para toMap() de las subclases.
  Map<String, dynamic> baseToMap() {
    return {
      'userId': userId,
      'name': name,
      'role': role,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}








