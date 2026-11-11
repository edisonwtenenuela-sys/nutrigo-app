import 'package:flutter/material.dart';
import 'package:emprendedor/presentation/entrepreneur/shared/widgets/entrepreneur_empty_state.dart';

class ProductsEmptyState extends StatelessWidget {
  final String selectedCategory;
  final bool hasProducts;
  final VoidCallback onCreateProduct;

  const ProductsEmptyState({
    super.key,
    required this.selectedCategory,
    required this.hasProducts,
    required this.onCreateProduct,
  });

  bool get _isAllCategories => selectedCategory == 'Todas';

  @override
  Widget build(BuildContext context) {
    if (hasProducts) {
      return const EntrepreneurEmptyState(
        icon: Icons.filter_alt_off_outlined,
        title: 'Sin productos en este filtro',
        subtitle:
            'Selecciona otro estado o categoría para ver más productos registrados.',
      );
    }

    return EntrepreneurEmptyState(
      icon: Icons.inventory_2_outlined,
      title: _isAllCategories
          ? 'Aún no tienes productos'
          : 'Sin productos en esta categoría',
      subtitle: _isAllCategories
          ? 'Crea tu primer producto saludable para enviarlo a validación nutricional.'
          : 'Prueba con otra categoría o registra un nuevo producto para ampliar tu catálogo.',
      actionLabel: 'Agregar producto',
      onAction: onCreateProduct,
    );
  }
}








