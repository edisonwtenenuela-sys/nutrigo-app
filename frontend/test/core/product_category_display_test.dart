import 'package:flutter_test/flutter_test.dart';

import 'package:emprendedor/core/utils/product_category_display.dart';

void main() {
  group('ProductCategoryDisplay.label', () {
    test('normalizes known healthy categories', () {
      expect(ProductCategoryDisplay.label('Ensaladas frescas'), 'Ensaladas');
      expect(ProductCategoryDisplay.label('Sopas nutritivas'), 'Sopas');
      expect(ProductCategoryDisplay.label('Bebidas naturales'), 'Bebidas');
      expect(ProductCategoryDisplay.label('Platos fitness'), 'Fitness');
      expect(ProductCategoryDisplay.label('Snacks proteicos'), 'Snacks');
      expect(ProductCategoryDisplay.label('Postres sin azucar'), 'Postres');
      expect(ProductCategoryDisplay.label('Keto'), 'Keto');
      expect(ProductCategoryDisplay.label('Vegano'), 'Vegano');
    });

    test('keeps unknown categories unchanged', () {
      expect(ProductCategoryDisplay.label('Desayunos'), 'Desayunos');
    });
  });

  group('ProductCategoryDisplay.summaryLabel', () {
    test('uses expanded label for all categories summary', () {
      expect(
        ProductCategoryDisplay.summaryLabel('Todas'),
        'Todas las categorías',
      );
    });
  });
}
