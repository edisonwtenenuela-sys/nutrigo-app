class CartItemModel {
  final String productId;
  final String name;
  final double price;
  final double? originalPrice;
  final String? imageUrl;

  final String? productOwnerId;

  final double? approxCalories;
  final bool isValidated;

  int quantity;

  CartItemModel({
    required this.productId,
    required this.name,
    required this.price,
    this.originalPrice,
    this.imageUrl,
    this.productOwnerId,
    this.approxCalories,
    this.isValidated = true,
    this.quantity = 1,
  });

  bool get hasDiscount =>
      originalPrice != null && originalPrice! > price + 0.009;

  double get total => price * quantity;

  double get originalTotal => (originalPrice ?? price) * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'productOwnerId': productOwnerId,
      'approxCalories': approxCalories,
      'isValidated': isValidated,
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> data) {
    return CartItemModel(
      productId: data['productId']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (data['originalPrice'] as num?)?.toDouble(),
      imageUrl: data['imageUrl']?.toString(),
      productOwnerId: data['productOwnerId']?.toString(),
      approxCalories: (data['approxCalories'] as num?)?.toDouble(),
      isValidated: data['isValidated'] as bool? ?? true,
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  CartItemModel copyWith({
    String? productId,
    String? name,
    double? price,
    double? originalPrice,
    String? imageUrl,
    String? productOwnerId,
    double? approxCalories,
    bool? isValidated,
    int? quantity,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      productOwnerId: productOwnerId ?? this.productOwnerId,
      approxCalories: approxCalories ?? this.approxCalories,
      isValidated: isValidated ?? this.isValidated,
      quantity: quantity ?? this.quantity,
    );
  }
}








