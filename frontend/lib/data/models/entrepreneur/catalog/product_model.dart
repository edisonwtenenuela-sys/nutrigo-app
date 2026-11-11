import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductStatus { available, unavailable }

enum NutritionValidationStatus { pending, approved, rejected }

extension ProductStatusExtension on ProductStatus {
  String get displayName {
    switch (this) {
      case ProductStatus.available:
        return 'Disponible';
      case ProductStatus.unavailable:
        return 'No Disponible';
    }
  }
}

extension NutritionValidationStatusExtension on NutritionValidationStatus {
  String get value {
    switch (this) {
      case NutritionValidationStatus.pending:
        return 'pending';
      case NutritionValidationStatus.approved:
        return 'approved';
      case NutritionValidationStatus.rejected:
        return 'rejected';
    }
  }

  String get displayName {
    switch (this) {
      case NutritionValidationStatus.pending:
        return 'Pendiente';
      case NutritionValidationStatus.approved:
        return 'Aprobado';
      case NutritionValidationStatus.rejected:
        return 'Rechazado';
    }
  }
}

NutritionValidationStatus stringToNutritionValidationStatus(String? value) {
  switch (value) {
    case 'approved':
      return NutritionValidationStatus.approved;
    case 'rejected':
      return NutritionValidationStatus.rejected;
    case 'pending':
    default:
      return NutritionValidationStatus.pending;
  }
}

class ProductModel {
  final String? id;
  final String name;
  final double price;
  final String? imageUrl;
  final ProductStatus status;
  final String category;
  final String description;
  final List<String> ingredients;
  final bool isFeatured;
  final String? userId;

  final String? servingSize;
  final double? approxCalories;
  final double? protein;
  final double? carbohydrates;
  final double? fats;
  final double? sodium;
  final double? sugar;
  final List<String> allergens;
  final List<String> dietaryTags;

  final NutritionValidationStatus validationStatus;
  final String? validatedByNutritionistId;
  final String? validatedByNutritionistName;
  final String? validationComment;
  final Timestamp? validatedAt;

  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  ProductModel({
    this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.status,
    required this.category,
    required this.description,
    required this.ingredients,
    this.isFeatured = false,
    this.userId,
    this.servingSize,
    this.approxCalories,
    this.protein,
    this.carbohydrates,
    this.fats,
    this.sodium,
    this.sugar,
    this.allergens = const [],
    this.dietaryTags = const [],
    this.validationStatus = NutritionValidationStatus.pending,
    this.validatedByNutritionistId,
    this.validatedByNutritionistName,
    this.validationComment,
    this.validatedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ProductModel(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl']?.toString(),
      status: data['status'] == 'available'
          ? ProductStatus.available
          : ProductStatus.unavailable,
      category: data['category']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      isFeatured: data['isFeatured'] as bool? ?? false,
      userId: data['userId']?.toString(),

      servingSize: data['servingSize']?.toString(),

      approxCalories: (data['approxCalories'] as num?)?.toDouble(),
      protein: (data['protein'] as num?)?.toDouble(),
      carbohydrates: (data['carbohydrates'] as num?)?.toDouble(),
      fats: (data['fats'] as num?)?.toDouble(),
      sodium: (data['sodium'] as num?)?.toDouble(),
      sugar: (data['sugar'] as num?)?.toDouble(),
      allergens: List<String>.from(data['allergens'] ?? []),
      dietaryTags: List<String>.from(data['dietaryTags'] ?? []),

      validationStatus: stringToNutritionValidationStatus(
        data['validationStatus']?.toString(),
      ),
      validatedByNutritionistId: data['validatedByNutritionistId']?.toString(),
      validatedByNutritionistName: data['validatedByNutritionistName']
          ?.toString(),
      validationComment: data['validationComment']?.toString(),
      validatedAt: data['validatedAt'] is Timestamp
          ? data['validatedAt'] as Timestamp
          : null,

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
      'price': price,
      'imageUrl': imageUrl,
      'status': status.name,
      'category': category,
      'description': description,
      'ingredients': ingredients,
      'isFeatured': isFeatured,
      'userId': userId,

      'servingSize': servingSize,

      'approxCalories': approxCalories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fats': fats,
      'sodium': sodium,
      'sugar': sugar,
      'allergens': allergens,
      'dietaryTags': dietaryTags,

      'validationStatus': validationStatus.value,
      'validatedByNutritionistId': validatedByNutritionistId,
      'validatedByNutritionistName': validatedByNutritionistName,
      'validationComment': validationComment,
      'validatedAt': validatedAt,

      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    String? imageUrl,
    ProductStatus? status,
    String? category,
    String? description,
    List<String>? ingredients,
    bool? isFeatured,
    String? userId,
    String? servingSize,
    double? approxCalories,
    double? protein,
    double? carbohydrates,
    double? fats,
    double? sodium,
    double? sugar,
    List<String>? allergens,
    List<String>? dietaryTags,
    NutritionValidationStatus? validationStatus,
    String? validatedByNutritionistId,
    String? validatedByNutritionistName,
    String? validationComment,
    Timestamp? validatedAt,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      category: category ?? this.category,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      isFeatured: isFeatured ?? this.isFeatured,
      userId: userId ?? this.userId,
      servingSize: servingSize ?? this.servingSize,
      approxCalories: approxCalories ?? this.approxCalories,
      protein: protein ?? this.protein,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      fats: fats ?? this.fats,
      sodium: sodium ?? this.sodium,
      sugar: sugar ?? this.sugar,
      allergens: allergens ?? this.allergens,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      validationStatus: validationStatus ?? this.validationStatus,
      validatedByNutritionistId:
          validatedByNutritionistId ?? this.validatedByNutritionistId,
      validatedByNutritionistName:
          validatedByNutritionistName ?? this.validatedByNutritionistName,
      validationComment: validationComment ?? this.validationComment,
      validatedAt: validatedAt ?? this.validatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}








