class OrderCardBusinessInfo {
  final String name;
  final String? imageUrl;
  final double rating;
  final int totalReviews;

  const OrderCardBusinessInfo({
    required this.name,
    required this.imageUrl,
    this.rating = 0,
    this.totalReviews = 0,
  });
}








