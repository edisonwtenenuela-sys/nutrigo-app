class ClientProfileModel {
  final String? id;
  final String userId;
  final String name;
  final String role;
  final String? phone;
  final String? address;
  final String? profileImageUrl;
  final bool isVerified;

  final double? latitude;
  final double? longitude;

  final int? age;
  final String? gender;
  final double? weight;
  final double? height;
  final String? dietaryGoal;
  final List<String> dietaryPreferences;
  final List<String> allergies;
  final List<String> medicalConditions;

  ClientProfileModel({
    this.id,
    required this.userId,
    required this.name,
    this.role = 'cliente',
    this.phone,
    this.address,
    this.profileImageUrl,
    this.isVerified = false,
    this.latitude,
    this.longitude,
    this.age,
    this.gender,
    this.weight,
    this.height,
    this.dietaryGoal,
    this.dietaryPreferences = const [],
    this.allergies = const [],
    this.medicalConditions = const [],
  });

  factory ClientProfileModel.fromMap(Map<String, dynamic> data, String id) {
    return ClientProfileModel(
      id: id,
      userId: data['userId']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      role: data['role']?.toString() ?? 'cliente',
      phone: data['phone']?.toString(),
      address: data['address']?.toString(),
      profileImageUrl: data['profileImageUrl']?.toString(),
      isVerified: data['isVerified'] as bool? ?? false,
      latitude: _toDouble(data['latitude']),
      longitude: _toDouble(data['longitude']),
      age: _toInt(data['age']),
      gender: data['gender']?.toString(),
      weight: _toDouble(data['weight']),
      height: _toDouble(data['height']),
      dietaryGoal: data['dietaryGoal']?.toString(),
      dietaryPreferences: _toStringList(data['dietaryPreferences']),
      allergies: _toStringList(data['allergies']),
      medicalConditions: _toStringList(data['medicalConditions']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'role': role,
      'phone': phone,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'isVerified': isVerified,
      'latitude': latitude,
      'longitude': longitude,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'dietaryGoal': dietaryGoal,
      'dietaryPreferences': dietaryPreferences,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
    };
  }

  ClientProfileModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? role,
    String? phone,
    String? address,
    String? profileImageUrl,
    bool? isVerified,
    double? latitude,
    double? longitude,
    int? age,
    String? gender,
    double? weight,
    double? height,
    String? dietaryGoal,
    List<String>? dietaryPreferences,
    List<String>? allergies,
    List<String>? medicalConditions,
  }) {
    return ClientProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isVerified: isVerified ?? this.isVerified,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      dietaryGoal: dietaryGoal ?? this.dietaryGoal,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return [];
  }
}








