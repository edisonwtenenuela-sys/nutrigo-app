class OrderBusinessSummary {
  const OrderBusinessSummary({
    required this.name,
    this.imageUrl,
    this.rating = 0,
    this.totalReviews = 0,
    this.openingHours,
    this.description,
  });

  final String name;
  final String? imageUrl;
  final double rating;
  final int totalReviews;
  final String? openingHours;
  final String? description;

  static const fallback = OrderBusinessSummary(name: 'Emprendedor');
}
