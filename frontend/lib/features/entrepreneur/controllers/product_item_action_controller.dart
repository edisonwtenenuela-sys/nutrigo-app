import 'dart:async';

import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/product_controller.dart';

class ProductItemActionResult {
  const ProductItemActionResult({
    required this.success,
    required this.title,
    required this.message,
  });

  final bool success;
  final String title;
  final String message;
}

class ProductItemActionController {
  const ProductItemActionController._();

  static Future<ProductItemActionResult> toggleFeatured({
    required ProductController controller,
    required ProductModel product,
    required bool value,
  }) async {
    final productId = product.id;
    if (productId == null || productId.trim().isEmpty) {
      return _invalidProductResult();
    }

    await _runWithTimeout(
      controller,
      () => controller.toggleFeaturedStatus(productId, value),
    );
    final success = controller.errorMessage == null;

    return ProductItemActionResult(
      success: success,
      title: success ? 'Producto actualizado' : 'No se pudo completar',
      message: success
          ? value
                ? 'Producto marcado como recomendado'
                : 'Producto quitado de recomendados'
          : controller.errorMessage ?? 'No se pudo actualizar.',
    );
  }

  static Future<ProductItemActionResult> toggleStatus({
    required ProductController controller,
    required ProductModel product,
  }) async {
    final productId = product.id;
    if (productId == null || productId.trim().isEmpty) {
      return _invalidProductResult();
    }

    await _runWithTimeout(
      controller,
      () => controller.toggleProductStatus(productId, product.status),
    );
    final success = controller.errorMessage == null;

    return ProductItemActionResult(
      success: success,
      title: success ? 'Producto actualizado' : 'No se pudo completar',
      message: success
          ? 'Estado actualizado'
          : controller.errorMessage ?? 'No se pudo cambiar el estado.',
    );
  }

  static Future<ProductItemActionResult> deleteProduct({
    required ProductController controller,
    required ProductModel product,
  }) async {
    final productId = product.id;
    if (productId == null || productId.trim().isEmpty) {
      return _invalidProductResult();
    }

    if (product.validationStatus == NutritionValidationStatus.pending) {
      return const ProductItemActionResult(
        success: false,
        title: 'Producto en revisión',
        message: 'No puedes eliminarlo mientras está pendiente de validación.',
      );
    }

    await _runWithTimeout(
      controller,
      () => controller.deleteProduct(productId, product.imageUrl),
    );
    final success = controller.errorMessage == null;

    return ProductItemActionResult(
      success: success,
      title: success ? 'Producto eliminado' : 'No se pudo completar',
      message: success
          ? 'Producto eliminado'
          : controller.errorMessage ?? 'Error al eliminar.',
    );
  }

  static ProductItemActionResult _invalidProductResult() {
    return const ProductItemActionResult(
      success: false,
      title: 'Producto inválido',
      message: 'No se encontró un identificador válido para este producto.',
    );
  }

  static Future<void> _runWithTimeout(
    ProductController controller,
    Future<void> Function() action,
  ) async {
    try {
      await action().timeout(const Duration(seconds: 18));
    } on TimeoutException {
      controller.clearLoadingState();
      controller.setActionError(
        'La operación tardó demasiado. Revisa tu conexión e inténtalo nuevamente.',
      );
    }
  }
}
