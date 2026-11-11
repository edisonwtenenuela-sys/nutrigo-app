import 'package:emprendedor/core/services/auth/user_session_service.dart';
import 'package:emprendedor/features/entrepreneur/controllers/order_controller.dart';

enum EntrepreneurOrderListUiState { loading, error, empty, content }

class EntrepreneurOrderListController {
  EntrepreneurOrderListController({UserSessionService? sessionService})
    : _sessionService = sessionService ?? UserSessionService();

  final UserSessionService _sessionService;
  String? _lastShownError;

  EntrepreneurOrderListUiState resolveUiState(OrderController controller) {
    final hasNoOrders = controller.orders.isEmpty;

    if (!controller.hasLoadedOrders && hasNoOrders) {
      return EntrepreneurOrderListUiState.loading;
    }

    if (controller.isLoading && hasNoOrders) {
      return EntrepreneurOrderListUiState.loading;
    }

    if (controller.errorMessage != null && hasNoOrders) {
      return EntrepreneurOrderListUiState.error;
    }

    if (hasNoOrders) return EntrepreneurOrderListUiState.empty;

    return EntrepreneurOrderListUiState.content;
  }

  Future<void> loadOrders(OrderController controller) async {
    final userId = _sessionService.currentUserId();
    if (userId == null) return;

    await controller.setBusinessUserId(userId);
  }

  String? consumeNewError(OrderController controller) {
    final message = controller.errorMessage;

    if (message == null || message.trim().isEmpty) return null;
    if (message == _lastShownError) return null;

    _lastShownError = message;
    return message;
  }
}








