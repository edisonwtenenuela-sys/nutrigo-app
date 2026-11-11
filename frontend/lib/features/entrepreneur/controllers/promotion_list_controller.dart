import 'package:emprendedor/data/models/entrepreneur/promotions/promotion_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/promotion_controller.dart';

class PromotionListActionResult {
  const PromotionListActionResult({
    required this.success,
    required this.title,
    required this.message,
  });

  final bool success;
  final String title;
  final String message;
}

enum PromotionsUiState { loading, error, empty, ready }

class PromotionListController {
  const PromotionListController._();

  static PromotionsUiState resolveUiState(PromotionController controller) {
    final hasPromotions = controller.promotions.isNotEmpty;

    if (!controller.hasLoadedPromotions && !hasPromotions) {
      return PromotionsUiState.loading;
    }

    if (controller.isLoading && !hasPromotions) {
      return PromotionsUiState.loading;
    }

    if (controller.errorMessage != null && !hasPromotions) {
      return PromotionsUiState.error;
    }

    if (!hasPromotions) return PromotionsUiState.empty;

    return PromotionsUiState.ready;
  }

  static Future<PromotionListActionResult> deletePromotion(
    PromotionController controller,
    PromotionModel promotion,
  ) async {
    final promotionId = promotion.id;
    if (promotionId == null || promotionId.trim().isEmpty) {
      return const PromotionListActionResult(
        success: false,
        title: 'Promoción inválida',
        message: 'No se encontró un identificador válido para eliminarla.',
      );
    }

    final success = await controller.deletePromotion(promotionId);

    return PromotionListActionResult(
      success: success,
      title: success ? 'Promoción eliminada' : 'No se pudo eliminar',
      message: success
          ? 'La promoción fue eliminada correctamente.'
          : 'Error: ${controller.errorMessage ?? "No se pudo completar la acción."}',
    );
  }
}








