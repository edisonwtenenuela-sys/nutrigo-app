import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessProfileModel {
  final String? id;
  final String? userId;
  final String name;
  final String role;

  final String? profileImageUrl;
  final String? description;
  final String? documentType;
  final String? documentNumber;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? openingHours;

  final double rating;
  final int totalReviews;

  final List<String> paymentMethods;
  final Map<String, String> socialMediaLinks;

  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  BusinessProfileModel({
    this.id,
    this.userId,
    this.name = '',
    this.role = 'emprendedor',
    this.profileImageUrl,
    this.description,
    this.documentType,
    this.documentNumber,
    this.address,
    this.latitude,
    this.longitude,
    this.phone,
    this.openingHours,
    this.rating = 0,
    this.totalReviews = 0,
    this.paymentMethods = const [],
    this.socialMediaLinks = const {},
    this.createdAt,
    this.updatedAt,
  });

  factory BusinessProfileModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return BusinessProfileModel(
      id: doc.id,
      userId: data['userId']?.toString(),
      name: data['name']?.toString() ?? '',
      role: data['role']?.toString() ?? 'emprendedor',
      profileImageUrl: data['profileImageUrl']?.toString(),
      description: data['description']?.toString(),
      documentType: data['documentType']?.toString(),
      documentNumber: data['documentNumber']?.toString(),
      address: data['address']?.toString(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      phone: data['phone']?.toString(),
      openingHours: data['openingHours']?.toString(),
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      totalReviews: (data['totalReviews'] as num?)?.toInt() ?? 0,
      paymentMethods: List<String>.from(data['paymentMethods'] ?? []),
      socialMediaLinks: Map<String, String>.from(
        data['socialMediaLinks'] ?? {},
      ),
      createdAt: data['createdAt'] is Timestamp
          ? data['createdAt'] as Timestamp
          : null,
      updatedAt: data['updatedAt'] is Timestamp
          ? data['updatedAt'] as Timestamp
          : null,
    );
  }

  Map<String, dynamic> toFirestore({bool deleteNullLocation = false}) {
    return {
      if (userId != null) 'userId': userId,
      'name': name,
      'role': role,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (description != null) 'description': description,
      if (documentType != null) 'documentType': documentType,
      if (documentNumber != null) 'documentNumber': documentNumber,
      if (address != null) 'address': address,
      if (latitude != null)
        'latitude': latitude
      else if (deleteNullLocation)
        'latitude': FieldValue.delete(),
      if (longitude != null)
        'longitude': longitude
      else if (deleteNullLocation)
        'longitude': FieldValue.delete(),
      if (phone != null) 'phone': phone,
      if (openingHours != null) 'openingHours': openingHours,
      'rating': rating,
      'totalReviews': totalReviews,
      'paymentMethods': paymentMethods,
      'socialMediaLinks': socialMediaLinks,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  BusinessProfileModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? role,
    String? profileImageUrl,
    String? description,
    String? documentType,
    String? documentNumber,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    String? openingHours,
    double? rating,
    int? totalReviews,
    List<String>? paymentMethods,
    Map<String, String>? socialMediaLinks,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return BusinessProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      description: description ?? this.description,
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      openingHours: openingHours ?? this.openingHours,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      socialMediaLinks: socialMediaLinks ?? this.socialMediaLinks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}








