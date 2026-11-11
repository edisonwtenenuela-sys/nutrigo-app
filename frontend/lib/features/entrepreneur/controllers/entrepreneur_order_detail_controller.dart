import 'package:flutter/material.dart';

import 'package:emprendedor/core/feedback/app_feedback_level.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/core/services/external_url_launcher_service.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/order_controller.dart';

enum EntrepreneurOrderDetailUiState { loading, error, notFound, ready }

class EntrepreneurOrderActionResult {
  const EntrepreneurOrderActionResult({
    required this.success,
    required this.type,
    required this.title,
    required this.message,
  });

  final bool success;
  final AppFeedbackLevel type;
  final String title;
  final String message;
}

class EntrepreneurOrderDetailController {
  EntrepreneurOrderDetailController({
    required this.orderId,
    ExternalUrlLauncherService launcher = const ExternalUrlLauncherService(),
  }) : _launcher = launcher;

  final String orderId;
  final ExternalUrlLauncherService _launcher;

  EntrepreneurOrderDetailUiState resolveUiState(OrderController controller) {
    final hasOrder = controller.selectedOrder != null;

    if (controller.isLoading && !hasOrder) {
      return EntrepreneurOrderDetailUiState.loading;
    }

    if (controller.errorMessage != null && !hasOrder) {
      return EntrepreneurOrderDetailUiState.error;
    }

    if (!hasOrder) return EntrepreneurOrderDetailUiState.notFound;

    return EntrepreneurOrderDetailUiState.ready;
  }

  Future<void> loadInitial(OrderController controller) async {
    controller.clearSelectedOrder();
    await controller.fetchOrderDetails(orderId);
  }

  Future<void> refresh(OrderController controller) {
    return controller.fetchOrderDetails(orderId);
  }

  Future<EntrepreneurOrderActionResult?> openDeliveryLocation({
    required double latitude,
    required double longitude,
  }) async {
    final opened = await _launcher.openExternalUrl(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (opened) return null;

    return const EntrepreneurOrderActionResult(
      success: false,
      type: AppFeedbackLevel.error,
      title: 'No se pudo abrir',
      message: 'No se pudo abrir Google Maps.',
    );
  }

  Future<EntrepreneurOrderActionResult> advanceStatus(
    OrderController controller,
    OrderModel order,
  ) async {
    final ok = await controller.advanceOrderStatus(order);

    if (!ok) {
      return EntrepreneurOrderActionResult(
        success: false,
        type: AppFeedbackLevel.error,
        title: 'No se pudo actualizar',
        message: controller.errorMessage ?? 'No se pudo avanzar el pedido.',
      );
    }

    await refresh(controller);

    return EntrepreneurOrderActionResult(
      success: true,
      type: AppFeedbackLevel.success,
      title: 'Estado actualizado',
      message: 'Estado actualizado a ${order.nextStatusText}.',
    );
  }

  Future<EntrepreneurOrderActionResult> cancelOrder(
    OrderController controller,
    OrderModel order,
  ) async {
    final ok = await controller.cancelOrder(order);

    if (!ok) {
      return EntrepreneurOrderActionResult(
        success: false,
        type: AppFeedbackLevel.error,
        title: 'No se pudo cancelar',
        message: controller.errorMessage ?? 'No se pudo cancelar este pedido.',
      );
    }

    await refresh(controller);

    return const EntrepreneurOrderActionResult(
      success: true,
      type: AppFeedbackLevel.warning,
      title: 'Pedido cancelado',
      message: 'El pedido fue cancelado correctamente.',
    );
  }

  Future<EntrepreneurOrderActionResult?> manualUpdateResult(
    OrderController controller,
    bool? updated,
  ) async {
    if (updated != true) return null;

    await refresh(controller);

    return const EntrepreneurOrderActionResult(
      success: true,
      type: AppFeedbackLevel.success,
      title: 'Estado actualizado',
      message: 'El estado del pedido se actualizó correctamente.',
    );
  }

  Color statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return RoleTheme.iconWarning;
      case OrderStatus.confirmed:
        return RoleTheme.iconValidation;
      case OrderStatus.preparing:
        return RoleTheme.iconInfo;
      case OrderStatus.shipped:
        return RoleTheme.brandSecondary;
      case OrderStatus.delivered:
        return RoleTheme.iconValidation;
      case OrderStatus.cancelled:
        return RoleTheme.iconDanger;
    }
  }

  Color paymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return RoleTheme.iconWarning;
      case PaymentStatus.paid:
        return RoleTheme.iconValidation;
      case PaymentStatus.failed:
        return RoleTheme.iconDanger;
      case PaymentStatus.refunded:
        return RoleTheme.brandSecondary;
    }
  }
}
