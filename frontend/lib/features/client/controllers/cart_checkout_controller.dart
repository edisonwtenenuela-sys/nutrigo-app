import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:emprendedor/core/services/payments/cart_payment_service.dart';
import 'package:emprendedor/data/models/shared/cart_item_model.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/features/client/controllers/cart_controller.dart';
import 'package:emprendedor/features/client/services/cart_checkout_service.dart';

class CartCheckoutResult {
  const CartCheckoutResult({required this.message, required this.order});

  final String message;
  final OrderModel order;
}

class CartFeedbackMessage {
  const CartFeedbackMessage({
    required this.message,
    this.title,
    this.isError = false,
  });

  final String message;
  final String? title;
  final bool isError;
}

class CartCheckoutController extends ChangeNotifier {
  CartCheckoutController({
    CartCheckoutService? checkoutService,
    CartPaymentService? paymentService,
  }) : _checkoutService = checkoutService ?? CartCheckoutService(),
       _paymentService = paymentService ?? CartPaymentService();

  static const cashPaymentMethod = 'Efectivo';
  static const onlinePaymentMethod = 'Pago en l\u00ednea';

  final CartCheckoutService _checkoutService;
  final CartPaymentService _paymentService;

  final addressController = TextEditingController();
  final couponController = TextEditingController();

  final Set<String> removingItems = {};
  final List<String> paymentMethods = const [
    cashPaymentMethod,
    onlinePaymentMethod,
  ];

  String? selectedPaymentMethod;
  double? latitude;
  double? longitude;
  bool isPaymentFlowActive = false;

  bool _hasLoadedDefaultLocation = false;
  bool _disposed = false;

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  Future<void> loadDefaultLocationIfNeeded() async {
    if (_hasLoadedDefaultLocation || addressController.text.trim().isNotEmpty) {
      return;
    }

    _hasLoadedDefaultLocation = true;

    final location = await _checkoutService.loadDefaultShippingLocation();
    if (location == null || !location.hasAddress) return;
    if (addressController.text.trim().isNotEmpty) return;

    updateLocation(
      address: location.address,
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }

  void updatePaymentMethod(String? value) {
    selectedPaymentMethod = value;
    _safeNotify();
  }

  void updateLocation({
    required String address,
    required double? latitude,
    required double? longitude,
  }) {
    addressController.text = address;
    this.latitude = latitude;
    this.longitude = longitude;
    _safeNotify();
  }

  Future<CartFeedbackMessage?> removeItemAnimated(
    CartController cart,
    CartItemModel item,
  ) async {
    if (removingItems.contains(item.productId)) return null;

    removingItems.add(item.productId);
    _safeNotify();

    await cart.removeProduct(item.productId);
    await Future.delayed(const Duration(milliseconds: 120));

    removingItems.remove(item.productId);
    _safeNotify();

    return CartFeedbackMessage(
      message: '${item.name} eliminado del carrito',
      title: 'Producto eliminado',
    );
  }

  Future<CartFeedbackMessage> applyCoupon(CartController cart) async {
    final success = await cart.applyCoupon(couponController.text);

    if (success) {
      couponController.clear();
      return const CartFeedbackMessage(
        message: 'Cup\u00f3n aplicado correctamente.',
        title: 'Cup\u00f3n aplicado',
      );
    }

    return CartFeedbackMessage(
      message: cart.couponMessage ?? 'No se pudo aplicar el cup\u00f3n.',
      isError: true,
    );
  }

  CartFeedbackMessage removeCoupon(CartController cart) {
    cart.removeCoupon();
    return const CartFeedbackMessage(
      message: 'Cup\u00f3n removido.',
      title: 'Cup\u00f3n removido',
    );
  }

  Future<CartCheckoutResult?> confirmOrder({
    required CartController cart,
    required VoidCallback showProcessingDialog,
    required VoidCallback closeProcessingDialog,
    required VoidCallback onCompletingCheckout,
    required void Function(CartFeedbackMessage feedback) onFeedback,
  }) async {
    final validationMessage = _validateCheckoutInputs(cart);
    if (validationMessage != null) {
      onFeedback(
        CartFeedbackMessage(message: validationMessage, isError: true),
      );
      return null;
    }

    final customer = await _checkoutService.loadCustomerData();

    if (selectedPaymentMethod == cashPaymentMethod) {
      onCompletingCheckout();

      final order = await cart
          .confirmOrder(
            shippingAddress: addressController.text.trim(),
            paymentMethod: 'cash',
            paymentStatus: PaymentStatus.pending,
            customerName: customer.name,
            customerEmail: customer.email,
            customerPhoneNumber: customer.phoneNumber,
            customerProfileImageUrl: customer.profileImageUrl,
            latitude: latitude,
            longitude: longitude,
          )
          .timeout(const Duration(seconds: 20), onTimeout: () => null);
      if (order == null) {
        cart.clearProcessingState();
      }

      return _orderResult(
        order: order,
        successMessage: 'Pedido realizado correctamente. Pago en efectivo.',
        fallbackErrorMessage:
            'No se pudo finalizar el pedido. Revisa tu conexión e inténtalo nuevamente.',
        cart: cart,
        onFeedback: onFeedback,
      );
    }

    return _processOnlinePaymentAndCreateOrder(
      cart: cart,
      customer: customer,
      showProcessingDialog: showProcessingDialog,
      closeProcessingDialog: closeProcessingDialog,
      onFeedback: onFeedback,
    );
  }

  String? _validateCheckoutInputs(CartController cart) {
    return _checkoutService.validateCheckoutInputs(
      cart: cart,
      hasAuthenticatedUser: _checkoutService.hasAuthenticatedUser,
      shippingAddress: addressController.text,
      selectedPaymentMethod: selectedPaymentMethod,
    );
  }

  Future<CartCheckoutResult?> _processOnlinePaymentAndCreateOrder({
    required CartController cart,
    required CustomerData customer,
    required VoidCallback showProcessingDialog,
    required VoidCallback closeProcessingDialog,
    required void Function(CartFeedbackMessage feedback) onFeedback,
  }) async {
    try {
      final amountInCents = (cart.finalTotal * 100).round();

      if (amountInCents <= 0) {
        onFeedback(
          const CartFeedbackMessage(
            message: 'El total del pedido no es v\u00e1lido.',
            isError: true,
          ),
        );
        return null;
      }

      final paymentIntent = await _paymentService.createPaymentIntent(
        amountInCents: amountInCents,
      );

      onFeedback(
        const CartFeedbackMessage(
          message:
              'Se abrir\u00e1 el m\u00e9todo de pago. Si no regresa autom\u00e1ticamente, vuelve a la app.',
          title: onlinePaymentMethod,
        ),
      );

      isPaymentFlowActive = true;
      showProcessingDialog();

      try {
        await _paymentService.showPaymentSheet(
          clientSecret: paymentIntent.clientSecret,
        );
      } finally {
        closeProcessingDialog();
        isPaymentFlowActive = false;
      }

      final order = await cart
          .confirmOrder(
            shippingAddress: addressController.text.trim(),
            paymentMethod: 'online',
            paymentStatus: PaymentStatus.paid,
            paymentIntentId: paymentIntent.paymentIntentId,
            customerName: customer.name,
            customerEmail: customer.email,
            customerPhoneNumber: customer.phoneNumber,
            customerProfileImageUrl: customer.profileImageUrl,
            latitude: latitude,
            longitude: longitude,
          )
          .timeout(const Duration(seconds: 20), onTimeout: () => null);
      if (order == null) {
        cart.clearProcessingState();
      }

      return _orderResult(
        order: order,
        successMessage: 'Pago realizado y pedido creado correctamente.',
        fallbackErrorMessage:
            'El pago se proces\u00f3, pero no se pudo crear el pedido.',
        cart: cart,
        onFeedback: onFeedback,
      );
    } on StripeException catch (e) {
      closeProcessingDialog();
      isPaymentFlowActive = false;
      onFeedback(
        CartFeedbackMessage(message: _stripeErrorMessage(e), isError: true),
      );
      return null;
    } on CartPaymentFailure catch (e) {
      closeProcessingDialog();
      isPaymentFlowActive = false;
      onFeedback(CartFeedbackMessage(message: e.message, isError: true));
      return null;
    } catch (_) {
      closeProcessingDialog();
      isPaymentFlowActive = false;
      onFeedback(
        const CartFeedbackMessage(
          message:
              'No se pudo completar el pago. Verifica la conexi\u00f3n e int\u00e9ntalo nuevamente.',
          isError: true,
        ),
      );
      return null;
    }
  }

  String _stripeErrorMessage(StripeException error) {
    final code = error.error.code.name.toLowerCase();
    final message = error.error.localizedMessage?.trim();
    final normalizedMessage = message?.toLowerCase() ?? '';
    final wasCancelled =
        code.contains('canceled') ||
        code.contains('cancelled') ||
        normalizedMessage.contains('cancel') ||
        normalizedMessage.contains('canceled') ||
        normalizedMessage.contains('cancelled');

    if (wasCancelled) {
      return 'Pago cancelado. No se creó ningún pedido.';
    }

    if (message == null || message.isEmpty) {
      return 'No se pudo completar el pago. Inténtalo nuevamente.';
    }

    return switch (normalizedMessage) {
      'the payment has been canceled' ||
      'the payment has been cancelled' ||
      'payment canceled' ||
      'payment cancelled' => 'Pago cancelado. No se creó ningún pedido.',
      _ => message,
    };
  }

  CartCheckoutResult? _orderResult({
    required OrderModel? order,
    required String successMessage,
    required String fallbackErrorMessage,
    required CartController cart,
    required void Function(CartFeedbackMessage feedback) onFeedback,
  }) {
    if (order != null) {
      return CartCheckoutResult(message: successMessage, order: order);
    }

    onFeedback(
      CartFeedbackMessage(
        message: cart.errorMessage ?? fallbackErrorMessage,
        isError: true,
      ),
    );
    return null;
  }

  @override
  void dispose() {
    _disposed = true;
    addressController.dispose();
    couponController.dispose();
    super.dispose();
  }
}
