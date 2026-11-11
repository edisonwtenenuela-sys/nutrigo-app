class ProductCategoryDisplay {
  const ProductCategoryDisplay._();

  static String label(String category) {
    final normalized = category.trim().toLowerCase();

    if (category == 'Todas') return 'Todas';
    if (normalized.contains('ensaladas')) return 'Ensaladas';
    if (normalized.contains('sopas')) return 'Sopas';
    if (normalized.contains('bebidas')) return 'Bebidas';
    if (normalized.contains('fitness')) return 'Fitness';
    if (normalized.contains('snacks')) return 'Snacks';
    if (normalized.contains('postres')) return 'Postres';
    if (normalized.contains('keto')) return 'Keto';
    if (normalized.contains('vegano')) return 'Vegano';

    return category
        .replaceAll(RegExp(r'\bsaludables\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\bsaludable\b', caseSensitive: false), '')
        .trim();
  }

  static String summaryLabel(String category) {
    if (category == 'Todas') return 'Todas las categor\u00edas';
    return label(category);
  }
}








