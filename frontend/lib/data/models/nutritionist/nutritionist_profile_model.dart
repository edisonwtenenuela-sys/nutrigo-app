import 'package:cloud_firestore/cloud_firestore.dart';

enum NutritionistConsultationMode { virtual, presencial, ambos }

NutritionistConsultationMode stringToNutritionistConsultationMode(
  String? value,
) {
  switch (value) {
    case 'presencial':
      return NutritionistConsultationMode.presencial;
    case 'ambos':
      return NutritionistConsultationMode.ambos;
    case 'virtual':
    default:
      return NutritionistConsultationMode.virtual;
  }
}

extension NutritionistConsultationModeX on NutritionistConsultationMode {
  String get value => name;

  String get label {
    switch (this) {
      case NutritionistConsultationMode.virtual:
        return 'Virtual';
      case NutritionistConsultationMode.presencial:
        return 'Presencial';
      case NutritionistConsultationMode.ambos:
        return 'Virtual y presencial';
    }
  }
}

class NutritionistProfileModel {
  final String? id;
  final String userId;
  final String name;
  final String role;
  final String? email;
  final String? phone;
  final String? profileImageUrl;
  final String? specialty;
  final String? professionalDescription;
  final String? licenseNumber;
  final String? professionalRegistryType;
  final NutritionistConsultationMode consultationMode;
  final double? consultationPrice;
  final List<String> availableDays;
  final String? attentionHours;

  final String? meetingLink;
  final String? consultationAddress;
  final double? consultationLatitude;
  final double? consultationLongitude;
  final String? consultationInstructions;

  final bool isAvailable;
  final bool isVerified;
  final String? verificationStatus;
  final String? verificationMessage;
  final int reviewsCount;
  final int reviewsSum;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  double get averageRating {
    if (reviewsCount <= 0) return 0;

    return reviewsSum / reviewsCount;
  }

  bool get hasReviews => reviewsCount > 0 && reviewsSum > 0;

  NutritionistProfileModel({
    this.id,
    required this.userId,
    required this.name,
    this.role = 'nutricionista',
    this.email,
    this.phone,
    this.profileImageUrl,
    this.specialty,
    this.professionalDescription,
    this.licenseNumber,
    this.professionalRegistryType,
    this.consultationMode = NutritionistConsultationMode.virtual,
    this.consultationPrice,
    this.availableDays = const [],
    this.attentionHours,
    this.meetingLink,
    this.consultationAddress,
    this.consultationLatitude,
    this.consultationLongitude,
    this.consultationInstructions,
    this.isAvailable = true,
    this.isVerified = false,
    this.verificationStatus,
    this.verificationMessage,
    this.reviewsCount = 0,
    this.reviewsSum = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory NutritionistProfileModel.fromMap(
    Map<String, dynamic> data,
    String id,
  ) {
    return NutritionistProfileModel(
      id: id,
      userId: data['userId']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      role: data['role']?.toString() ?? 'nutricionista',
      email: data['email']?.toString(),
      phone: data['phone']?.toString(),
      profileImageUrl: data['profileImageUrl']?.toString(),
      specialty: data['specialty']?.toString(),
      professionalDescription: data['professionalDescription']?.toString(),
      licenseNumber:
          data['professionalLicense']?.toString() ??
          data['licenseNumber']?.toString(),
      professionalRegistryType: data['professionalRegistryType']?.toString(),
      consultationMode: stringToNutritionistConsultationMode(
        data['consultationMode']?.toString(),
      ),
      consultationPrice: (data['consultationPrice'] as num?)?.toDouble(),
      availableDays: List<String>.from(data['availableDays'] ?? []),
      attentionHours: data['attentionHours']?.toString(),
      meetingLink: data['meetingLink']?.toString(),
      consultationAddress: data['consultationAddress']?.toString(),
      consultationLatitude: (data['consultationLatitude'] as num?)?.toDouble(),
      consultationLongitude: (data['consultationLongitude'] as num?)
          ?.toDouble(),
      consultationInstructions: data['consultationInstructions']?.toString(),
      isAvailable: data['isAvailable'] as bool? ?? true,
      isVerified: data['isVerified'] as bool? ?? false,
      verificationStatus: data['verificationStatus']?.toString(),
      verificationMessage: data['verificationMessage']?.toString(),
      reviewsCount: (data['reviewsCount'] as num?)?.toInt() ?? 0,
      reviewsSum: (data['reviewsSum'] as num?)?.toInt() ?? 0,
      createdAt: data['createdAt'] is Timestamp
          ? data['createdAt'] as Timestamp
          : null,
      updatedAt: data['updatedAt'] is Timestamp
          ? data['updatedAt'] as Timestamp
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'role': role,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'specialty': specialty,
      'professionalDescription': professionalDescription,
      'licenseNumber': licenseNumber,
      'professionalRegistryType': professionalRegistryType,
      'consultationMode': consultationMode.value,
      'consultationPrice': consultationPrice,
      'availableDays': availableDays,
      'attentionHours': attentionHours,
      'meetingLink': meetingLink,
      'consultationAddress': consultationAddress,
      'consultationLatitude': consultationLatitude,
      'consultationLongitude': consultationLongitude,
      'consultationInstructions': consultationInstructions,
      'isAvailable': isAvailable,
      'isVerified': isVerified,
      'verificationStatus': verificationStatus,
      'verificationMessage': verificationMessage,
      'reviewsCount': reviewsCount,
      'reviewsSum': reviewsSum,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  NutritionistProfileModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? role,
    String? email,
    String? phone,
    String? profileImageUrl,
    String? specialty,
    String? professionalDescription,
    String? licenseNumber,
    String? professionalRegistryType,
    NutritionistConsultationMode? consultationMode,
    double? consultationPrice,
    List<String>? availableDays,
    String? attentionHours,
    String? meetingLink,
    String? consultationAddress,
    double? consultationLatitude,
    double? consultationLongitude,
    String? consultationInstructions,
    bool? isAvailable,
    bool? isVerified,
    String? verificationStatus,
    String? verificationMessage,
    int? reviewsCount,
    int? reviewsSum,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return NutritionistProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      specialty: specialty ?? this.specialty,
      professionalDescription:
          professionalDescription ?? this.professionalDescription,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      professionalRegistryType:
          professionalRegistryType ?? this.professionalRegistryType,
      consultationMode: consultationMode ?? this.consultationMode,
      consultationPrice: consultationPrice ?? this.consultationPrice,
      availableDays: availableDays ?? this.availableDays,
      attentionHours: attentionHours ?? this.attentionHours,
      meetingLink: meetingLink ?? this.meetingLink,
      consultationAddress: consultationAddress ?? this.consultationAddress,
      consultationLatitude: consultationLatitude ?? this.consultationLatitude,
      consultationLongitude:
          consultationLongitude ?? this.consultationLongitude,
      consultationInstructions:
          consultationInstructions ?? this.consultationInstructions,
      isAvailable: isAvailable ?? this.isAvailable,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationMessage: verificationMessage ?? this.verificationMessage,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      reviewsSum: reviewsSum ?? this.reviewsSum,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
