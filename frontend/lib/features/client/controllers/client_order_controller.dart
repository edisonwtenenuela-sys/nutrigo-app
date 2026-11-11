import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/data/repositories/shared/order_repository.dart';

final Logger _logger = Logger('ClientOrderController');

class ClientOrderController extends ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  OrderModel? _selectedOrder;
  OrderModel? get selectedOrder => _selectedOrder;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _userId;
  bool get _hasValidUserId => _userId != null && _userId!.trim().isNotEmpty;

  StreamSubscription<List<OrderModel>>? _ordersSubscription;
  Completer<void>? _ordersReadyCompleter;

  Future<void> setUserId(String? userId) async {
    if (_userId == userId && _ordersSubscription != null) {
      await _ordersReadyCompleter?.future;
      return;
    }

    await _cancelOrdersSubscription();
    _userId = userId;

    if (!_hasValidUserId) {
      _resetState(notify: true);
      return;
    }

    await fetchOrders();
  }

  Future<void> refreshOrders() async {
    if (!_hasValidUserId) return;
    await _cancelOrdersSubscription();
    await fetchOrders();
  }

  Future<void> fetchOrders() async {
    if (!_ensureUserContext(
      'Usuario no autenticado. No se pueden cargar pedidos.',
    )) {
      return;
    }

    _setState(isLoading: true, errorMessage: null);

    try {
      await _cancelOrdersSubscription();
      final readyCompleter = Completer<void>();
      _ordersReadyCompleter = readyCompleter;

      _ordersSubscription = _orderRepository
          .getOrders(_userId!)
          .listen(
            (ordersData) {
              _applyOrdersUpdate(ordersData);
              if (!readyCompleter.isCompleted) readyCompleter.complete();
            },
            onError: (error, stackTrace) {
              _logger.severe(
                'Error al cargar pedidos del cliente',
                error,
                stackTrace,
              );
              _orders = [];
              _setState(
                errorMessage:
                    'No se pudieron cargar los pedidos. ${friendlyErrorMessage(error)}',
                isLoading: false,
              );
              if (!readyCompleter.isCompleted) readyCompleter.complete();
            },
          );
      await readyCompleter.future;
    } catch (e, stackTrace) {
      _logger.severe(
        'Excepcion al iniciar carga de pedidos del cliente',
        e,
        stackTrace,
      );
      _orders = [];
      _setState(
        errorMessage:
            'No se pudieron cargar los pedidos. ${friendlyErrorMessage(e)}',
        isLoading: false,
      );
      final pendingReady = _ordersReadyCompleter;
      if (pendingReady != null && !pendingReady.isCompleted) {
        pendingReady.complete();
      }
    }
  }

  Future<void> fetchOrderDetails(String orderId) async {
    if (!_ensureUserContext(
      'Usuario no autenticado. No se puede cargar el pedido.',
    )) {
      return;
    }

    _setState(isLoading: true, errorMessage: null);

    try {
      final order = await _orderRepository.getOrderById(orderId, _userId!);

      if (order == null) {
        _selectedOrder = null;
        _setState(
          errorMessage: 'El pedido no existe o no tienes permiso para verlo.',
          isLoading: false,
        );
        return;
      }

      _selectedOrder = order;
      _setState(isLoading: false, errorMessage: null);
    } catch (e, stackTrace) {
      _logger.severe('Error al cargar detalle del pedido', e, stackTrace);
      _selectedOrder = null;
      _setState(
        errorMessage:
            'No se pudo cargar el detalle del pedido. ${friendlyErrorMessage(e)}',
        isLoading: false,
      );
    }
  }

  Future<bool> updatePaymentStatus({
    required String orderId,
    required PaymentStatus paymentStatus,
    String? paymentIntentId,
  }) async {
    if (!_ensureUserContext('Usuario no autenticado.')) return false;

    _setState(isLoading: true, errorMessage: null);

    try {
      await _orderRepository.updatePaymentStatusForClient(
        orderId,
        paymentStatus,
        _userId!,
        paymentIntentId: paymentIntentId,
      );

      _setState(isLoading: false, errorMessage: null);
      return true;
    } catch (e, stackTrace) {
      _logger.severe('Error al actualizar pago del pedido', e, stackTrace);
      _setState(
        errorMessage:
            'No se pudo actualizar el pago. ${friendlyErrorMessage(e)}',
        isLoading: false,
      );
      return false;
    }
  }

  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  Future<void> _cancelOrdersSubscription() async {
    final pendingReady = _ordersReadyCompleter;
    if (pendingReady != null && !pendingReady.isCompleted) {
      pendingReady.complete();
    }
    _ordersReadyCompleter = null;
    await _ordersSubscription?.cancel();
    _ordersSubscription = null;
  }

  bool _ensureUserContext(String message) {
    if (_hasValidUserId) return true;
    _setState(errorMessage: message, isLoading: false);
    return false;
  }

  void _applyOrdersUpdate(List<OrderModel> ordersData) {
    _orders = ordersData;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _resetState({bool notify = false}) {
    _orders = [];
    _selectedOrder = null;
    _errorMessage = null;
    _isLoading = false;
    if (notify) notifyListeners();
  }

  void _setState({bool? isLoading, String? errorMessage, bool notify = true}) {
    if (isLoading != null) _isLoading = isLoading;
    _errorMessage = errorMessage;
    if (notify) notifyListeners();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    _ordersSubscription = null;
    _resetState(notify: false);
    super.dispose();
  }
}
