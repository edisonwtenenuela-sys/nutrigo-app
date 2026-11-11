import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { cliente, emprendedor, nutricionista, admin }

UserRole stringToUserRole(String? value) {
  switch (value) {
    case 'emprendedor':
      return UserRole.emprendedor;
    case 'nutricionista':
      return UserRole.nutricionista;
    case 'admin':
      return UserRole.admin;
    case 'cliente':
    default:
      return UserRole.cliente;
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final UserRole role;

  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.role = UserRole.cliente,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return UserModel(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phoneNumber: data['phoneNumber']?.toString(),
      profileImageUrl: data['profileImageUrl']?.toString(),
      role: stringToUserRole(data['role']?.toString()),
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
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'role': role.name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Map<String, dynamic> toEmbeddedData() {
    return {
      'userId': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'role': role.name,
    };
  }

  factory UserModel.fromEmbeddedData(Map<String, dynamic> data) {
    return UserModel(
      id: data['userId']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phoneNumber: data['phoneNumber']?.toString(),
      profileImageUrl: data['profileImageUrl']?.toString(),
      role: stringToUserRole(data['role']?.toString()),
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    UserRole? role,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}








