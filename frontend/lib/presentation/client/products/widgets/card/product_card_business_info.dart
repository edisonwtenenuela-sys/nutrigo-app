class ProductCardBusinessInfo {
  final String name;
  final String? imageUrl;
  final double rating;
  final int totalReviews;
  final String? openingHours;
  final String? description;

  const ProductCardBusinessInfo({
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.totalReviews,
    this.openingHours,
    this.description,
  });
}
