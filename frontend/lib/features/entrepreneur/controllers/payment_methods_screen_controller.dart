import 'package:emprendedor/core/services/auth/user_session_service.dart';
import 'package:emprendedor/data/models/entrepreneur/payments/payment_method_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/payment_method_controller.dart';

enum PaymentMethodsUiState { loading, error, empty, ready }

class PaymentMethodActionResult {
  const PaymentMethodActionResult({
    required this.success,
    required this.title,
    required this.message,
  });

  final bool success;
  final String title;
  final String message;
}

class PaymentMethodsScreenController {
  PaymentMethodsScreenController({UserSessionService? sessionService})
    : _sessionService = sessionService ?? UserSessionService();

  final UserSessionService _sessionService;

  PaymentMethodsUiState resolveUiState(PaymentMethodController controller) {
    final hasNoMethods = controller.paymentMethods.isEmpty;

    if (controller.isLoading && hasNoMethods) {
      return PaymentMethodsUiState.loading;
    }

    if (controller.errorMessage != null && hasNoMethods) {
      return PaymentMethodsUiState.error;
    }

    if (hasNoMethods) return PaymentMethodsUiState.empty;

    return PaymentMethodsUiState.ready;
  }

  Future<void> load(PaymentMethodController controller) async {
    final userId = _sessionService.currentUserId();
    if (userId == null) return;

    await controller.setUserId(userId);
  }

  Future<void> refresh(PaymentMethodController controller) async {
    final userId = _sessionService.currentUserId();
    if (userId == null) return;

    await controller.setUserId(userId);
    await controller.fetchPaymentMethods();
  }

  Future<PaymentMethodActionResult> addPaymentMethod(
    PaymentMethodController controller,
    PaymentType type,
  ) async {
    final success = await controller.addPaymentMethod(
      PaymentMethodModel(
        type: type,
        details: {'descripcion': _creationDescription(type)},
      ),
    );

    return PaymentMethodActionResult(
      success: success,
      title: success ? 'Método actualizado' : 'No se pudo guardar',
      message: success
          ? 'Método agregado correctamente.'
          : controller.errorMessage ?? 'No se pudo agregar.',
    );
  }

  Future<PaymentMethodActionResult> updatePaymentMethod(
    PaymentMethodController controller,
    PaymentMethodModel item,
  ) async {
    final success = await controller.updatePaymentMethod(item);

    return PaymentMethodActionResult(
      success: success,
      title: success ? 'Método actualizado' : 'No se pudo guardar',
      message: success
          ? 'Método actualizado correctamente.'
          : controller.errorMessage ?? 'No se pudo actualizar.',
    );
  }

  Future<PaymentMethodActionResult> deletePaymentMethod(
    PaymentMethodController controller,
    PaymentMethodModel item,
  ) async {
    final id = item.id;
    if (id == null || id.trim().isEmpty) {
      return const PaymentMethodActionResult(
        success: false,
        title: 'No se pudo guardar',
        message: 'No se pudo identificar el método de pago.',
      );
    }

    final success = await controller.deletePaymentMethod(id);

    return PaymentMethodActionResult(
      success: success,
      title: success ? 'Método actualizado' : 'No se pudo guardar',
      message: success
          ? 'Método eliminado correctamente.'
          : controller.errorMessage ?? 'No se pudo eliminar.',
    );
  }

  String _creationDescription(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return 'Pago en efectivo';
      case PaymentType.online:
        return 'Pago en linea mediante Stripe';
    }
  }
}








