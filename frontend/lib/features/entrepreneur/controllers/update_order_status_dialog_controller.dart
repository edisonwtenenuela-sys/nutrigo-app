import 'package:flutter/material.dart';

import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/order_controller.dart';

class UpdateOrderStatusDialogController extends ChangeNotifier {
  final String orderId;
  final OrderStatus currentStatus;
  final OrderController _orderController;

  UpdateOrderStatusDialogController({
    required this.orderId,
    required this.currentStatus,
    required OrderController orderController,
  }) : _orderController = orderController,
       _selectedStatus = currentStatus,
       statusOptions = validOptionsFor(currentStatus) {
    _orderController.clearErrorMessage();
  }

  OrderStatus _selectedStatus;
  OrderStatus get selectedStatus => _selectedStatus;

  final List<OrderStatus> statusOptions;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get hasChanged => _selectedStatus != currentStatus;

  static List<OrderStatus> validOptionsFor(OrderStatus currentStatus) {
    switch (currentStatus) {
      case OrderStatus.pending:
        return const [
          OrderStatus.pending,
          OrderStatus.confirmed,
          OrderStatus.cancelled,
        ];
      case OrderStatus.confirmed:
        return const [
          OrderStatus.confirmed,
          OrderStatus.preparing,
          OrderStatus.cancelled,
        ];
      case OrderStatus.preparing:
        return const [
          OrderStatus.preparing,
          OrderStatus.shipped,
          OrderStatus.cancelled,
        ];
      case OrderStatus.shipped:
        return const [OrderStatus.shipped, OrderStatus.delivered];
      case OrderStatus.delivered:
        return const [OrderStatus.delivered];
      case OrderStatus.cancelled:
        return const [OrderStatus.cancelled];
    }
  }

  void updateSelectedStatus(OrderStatus status) {
    if (_isUpdating || _selectedStatus == status) return;
    _selectedStatus = status;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> updateStatus() async {
    if (_isUpdating || !hasChanged) return false;

    _setUpdating(true);
    _errorMessage = null;

    try {
      final success = await _orderController
          .updateOrderStatus(orderId, _selectedStatus)
          .timeout(const Duration(seconds: 15));

      if (!success) {
        _errorMessage =
            _orderController.errorMessage ?? 'No se pudo actualizar.';
      }

      return success;
    } catch (e) {
      _errorMessage =
          'No se pudo actualizar el estado. ${friendlyErrorMessage(e)}';
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  void _setUpdating(bool value) {
    if (_isUpdating == value) return;
    _isUpdating = value;
    notifyListeners();
  }
}
