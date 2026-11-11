import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/data/repositories/shared/order_repository.dart';

final Logger _logger = Logger('OrderController');

class OrderController extends ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  OrderModel? _selectedOrder;
  OrderModel? get selectedOrder => _selectedOrder;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasLoadedOrders = false;
  bool get hasLoadedOrders => _hasLoadedOrders;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _businessUserId;
  String? get businessUserId => _businessUserId;

  bool get _hasValidBusinessUserId =>
      _businessUserId != null && _businessUserId!.trim().isNotEmpty;

  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  Future<void> setBusinessUserId(String? businessUserId) async {
    if (_businessUserId == businessUserId) return;

    await _cancelOrdersSubscription();
    _businessUserId = businessUserId;

    if (!_hasValidBusinessUserId) {
      _clearOrdersState();
      _hasLoadedOrders = true;
      return;
    }

    await fetchOrders();
  }

  Future<void> reset() async {
    await _cancelOrdersSubscription();
    _businessUserId = null;
    _clearOrdersState();
  }

  double get totalVentas {
    return _orders
        .where(
          (order) =>
              order.paymentStatus == PaymentStatus.paid &&
              order.status == OrderStatus.delivered,
        )
        .fold(0.0, (sum, order) => sum + order.totalPrice);
  }

  int get totalPedidos => _orders.length;

  int get paidOrders => _orders
      .where(
        (order) =>
            order.paymentStatus == PaymentStatus.paid &&
            order.status == OrderStatus.delivered,
      )
      .length;

  int get pendingPaymentOrders => _orders
      .where((order) => order.paymentStatus == PaymentStatus.pending)
      .length;

  int get activeOrders => _orders
      .where(
        (order) =>
            order.status != OrderStatus.delivered &&
            order.status != OrderStatus.cancelled,
      )
      .length;

  Future<void> fetchOrders() async {
    if (!_ensureBusinessContext()) return;

    _setLoading(true);
    _clearError();

    try {
      await _cancelOrdersSubscription();

      _ordersSubscription = _orderRepository
          .getOrdersForBusiness(_businessUserId!)
          .listen(
            _applyOrdersUpdate,
            onError: (error, stackTrace) {
              _logger.warning('No se pudieron cargar pedidos: $error');
              _orders = [];
              _hasLoadedOrders = true;
              _setError('No se pudieron cargar los pedidos.');
              _setLoading(false);
            },
          );
    } catch (e, stackTrace) {
      _logger.warning('Carga de pedidos omitida temporalmente.', e, stackTrace);
      _orders = [];
      _hasLoadedOrders = true;
      _setLoading(false);
    }
  }

  Future<void> fetchOrderDetails(String orderId) async {
    if (!_ensureBusinessContext()) return;

    _setLoading(true);
    _clearError();

    try {
      _selectedOrder = await _orderRepository.getOrderByIdForBusiness(
        orderId,
        _businessUserId!,
      );

      _setLoading(false);
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.severe('Error detalles pedido', e, stackTrace);
      _setError(
        'No se pudo cargar el detalle del pedido. ${friendlyErrorMessage(e)}',
      );
      _setLoading(false);
    }
  }

  Future<bool> advanceOrderStatus(OrderModel order) async {
    final next = order.nextStatus;

    if (next == null) {
      _setError('El pedido ya está finalizado.');
      return false;
    }

    return updateOrderStatus(order.id!, next);
  }

  Future<bool> cancelOrder(OrderModel order) async {
    if (!order.canBeCancelled) {
      _setError('No se puede cancelar este pedido.');
      return false;
    }

    return updateOrderStatus(order.id!, OrderStatus.cancelled);
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    if (!_ensureBusinessContext()) return false;

    _clearError();
    _setLoading(true);

    try {
      await _orderRepository
          .updateOrderStatusForBusiness(orderId, newStatus, _businessUserId!)
          .timeout(const Duration(seconds: 12));
      return true;
    } catch (e, stackTrace) {
      _logger.severe('Error al actualizar estado', e, stackTrace);
      _setError(
        'No se pudo actualizar el estado del pedido. ${friendlyErrorMessage(e)}',
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePaymentStatus(
    String orderId,
    PaymentStatus newPaymentStatus,
  ) async {
    if (!_ensureBusinessContext()) return false;

    _clearError();

    try {
      await _orderRepository
          .updatePaymentStatusForBusiness(
            orderId,
            newPaymentStatus,
            _businessUserId!,
          )
          .timeout(const Duration(seconds: 12));
      return true;
    } catch (e, stackTrace) {
      _logger.severe('Error pago', e, stackTrace);
      _setError('No se pudo actualizar el pago. ${friendlyErrorMessage(e)}');
      return false;
    }
  }

  String getNextActionText(OrderModel order) {
    return order.nextStatusText;
  }

  bool canAdvance(OrderModel order) {
    return order.nextStatus != null;
  }

  bool canCancel(OrderModel order) {
    return order.canBeCancelled;
  }

  void clearErrorMessage() {
    _clearError();
  }

  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  Future<void> _cancelOrdersSubscription() async {
    await _ordersSubscription?.cancel();
    _ordersSubscription = null;
  }

  void _applyOrdersUpdate(List<OrderModel> ordersData) {
    _orders = ordersData;
    _hasLoadedOrders = true;
    _setLoading(false);
    notifyListeners();
  }

  bool _ensureBusinessContext() {
    return _hasValidBusinessUserId;
  }

  void _clearOrdersState() {
    _orders = [];
    _selectedOrder = null;
    _errorMessage = null;
    _isLoading = false;
    _hasLoadedOrders = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    if (_errorMessage == message) return;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
