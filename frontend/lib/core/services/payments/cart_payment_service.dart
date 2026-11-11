import 'package:cloud_functions/cloud_functions.dart';
import 'package:emprendedor/core/services/payments/stripe_payment_bootstrap.dart';
import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class CartPaymentFailure implements Exception {
  const CartPaymentFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class PaymentIntentResult {
  final String clientSecret;
  final String? paymentIntentId;

  const PaymentIntentResult({
    required this.clientSecret,
    required this.paymentIntentId,
  });
}

class CartPaymentService {
  Future<User?> _resolveCurrentUser() async {
    final auth = FirebaseAuth.instance;

    for (var attempt = 0; attempt < 25; attempt++) {
      final currentUser = auth.currentUser;
      if (currentUser != null) return currentUser;
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }

    try {
      return await auth
          .idTokenChanges()
          .firstWhere((user) => user != null)
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      return null;
    }
  }

  Future<void> _ensureAuthenticatedCall() async {
    final user = await _resolveCurrentUser();
    if (user == null) {
      throw const CartPaymentFailure(
        'Tu sesión no está activa. Cierra sesión e ingresa nuevamente.',
      );
    }

    await user.getIdToken(true);
  }

  Future<PaymentIntentResult> createPaymentIntent({
    required int amountInCents,
    String currency = 'usd',
  }) async {
    try {
      await _ensureAuthenticatedCall();

      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final callable = functions.httpsCallable('createOrderPaymentIntent');

      final result = await callable.call(<String, dynamic>{
        'amount': amountInCents,
        'currency': currency,
      });

      final responseData = Map<String, dynamic>.from(result.data as Map);
      final clientSecret = responseData['clientSecret'] as String?;
      final paymentIntentId = responseData['paymentIntentId'] as String?;

      if (clientSecret == null || clientSecret.isEmpty) {
        throw const CartPaymentFailure(
          'No se recibió el clientSecret del pago.',
        );
      }

      return PaymentIntentResult(
        clientSecret: clientSecret,
        paymentIntentId: paymentIntentId,
      );
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'unauthenticated') {
        throw const CartPaymentFailure(
          'Tu sesión no está activa. Cierra sesión e ingresa nuevamente.',
        );
      }
      throw CartPaymentFailure(
        friendlyErrorMessage(
          e,
          fallback: 'No se pudo preparar el pago. Inténtalo nuevamente.',
        ),
      );
    }
  }

  Future<void> showPaymentSheet({
    required String clientSecret,
    String merchantDisplayName = 'NutriGo',
  }) async {
    await StripePaymentBootstrap.ensureInitialized();

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: merchantDisplayName,
      ),
    );

    try {
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (e) {
      throw CartPaymentFailure(_friendlyStripeMessage(e));
    } on PlatformException catch (e) {
      throw CartPaymentFailure(_friendlyPlatformPaymentMessage(e));
    } catch (e) {
      throw CartPaymentFailure(_friendlyGenericPaymentMessage(e));
    }
  }

  String _friendlyStripeMessage(StripeException error) {
    final rawMessage = error.error.localizedMessage?.trim();
    final normalized = '${error.error.code.name} ${rawMessage ?? ''}'
        .toLowerCase();

    if (_isCanceledPaymentMessage(normalized)) {
      return 'Pago cancelado. No se creó ningún pedido.';
    }

    return rawMessage?.isNotEmpty == true
        ? rawMessage!
        : 'No se pudo completar el pago. Inténtalo nuevamente.';
  }

  String _friendlyPlatformPaymentMessage(PlatformException error) {
    final normalized = '${error.code} ${error.message ?? ''}'.toLowerCase();

    if (_isCanceledPaymentMessage(normalized)) {
      return 'Pago cancelado. No se creó ningún pedido.';
    }

    return friendlyErrorMessage(
      error,
      fallback: 'No se pudo completar el pago. Inténtalo nuevamente.',
    );
  }

  String _friendlyGenericPaymentMessage(Object error) {
    final normalized = error.toString().toLowerCase();

    if (_isCanceledPaymentMessage(normalized)) {
      return 'Pago cancelado. No se creó ningún pedido.';
    }

    return 'No se pudo completar el pago. Inténtalo nuevamente.';
  }

  bool _isCanceledPaymentMessage(String value) {
    return value.contains('cancel') ||
        value.contains('canceled') ||
        value.contains('cancelled') ||
        value.contains('payment flow has been canceled');
  }
}
