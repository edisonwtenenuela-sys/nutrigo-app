import 'package:emprendedor/features/entrepreneur/controllers/product_controller.dart';

enum ProductListUiState { error, empty, content }

class ProductListController {
  const ProductListController._();

  static ProductListUiState resolveUiState(ProductController controller) {
    final hasProducts = controller.products.isNotEmpty;

    if (!controller.hasLoadedProducts && !hasProducts) {
      return ProductListUiState.content;
    }

    if (controller.errorMessage != null && !hasProducts) {
      return ProductListUiState.error;
    }

    if (!hasProducts && !controller.isLoading) {
      return ProductListUiState.empty;
    }

    return ProductListUiState.content;
  }
}








