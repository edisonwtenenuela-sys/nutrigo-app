import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';

class ClientProductsSearchHelper {
  static bool matchesSearch(ProductModel product, String query) {
    if (query.trim().isEmpty) return true;

    final normalizedQuery = query.toLowerCase().trim();

    final name = product.name.toLowerCase();
    final description = product.description.toLowerCase();
    final category = product.category.toLowerCase();
    final ingredients = product.ingredients.join(' ').toLowerCase();
    final dietaryTags = product.dietaryTags.join(' ').toLowerCase();

    return name.contains(normalizedQuery) ||
        description.contains(normalizedQuery) ||
        category.contains(normalizedQuery) ||
        ingredients.contains(normalizedQuery) ||
        dietaryTags.contains(normalizedQuery);
  }

  static List<ProductModel> filterProducts(
    List<ProductModel> products,
    String searchText,
  ) {
    return products.where((product) {
      return matchesSearch(product, searchText);
    }).toList();
  }
}








