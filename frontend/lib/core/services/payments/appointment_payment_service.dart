import 'package:cloud_functions/cloud_functions.dart';
import 'package:emprendedor/core/services/payments/stripe_payment_bootstrap.dart';
import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class AppointmentPaymentFailure implements Exception {
  const AppointmentPaymentFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class AppointmentPaymentIntentResult {
  const AppointmentPaymentIntentResult({
    required this.clientSecret,
    required this.paymentIntentId,
  });

  final String clientSecret;
  final String? paymentIntentId;
}

class AppointmentPaymentService {
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

  Future<String> _ensureAuthenticatedCall() async {
    final user = await _resolveCurrentUser();
    if (user == null) {
      debugPrint(
        '[AppointmentPaymentService] currentUser null antes de crear cita.',
      );
      throw const AppointmentPaymentFailure(
        'Tu sesión no está activa. Cierra sesión e ingresa nuevamente.',
      );
    }

    final idToken = await user.getIdToken(true);
    debugPrint('[AppointmentPaymentService] UID listo para cita: ${user.uid}');
    return idToken ?? '';
  }

  Future<AppointmentPaymentIntentResult> createPaymentIntent({
    required int amountInCents,
    required String nutritionistUserId,
    String currency = 'usd',
  }) async {
    try {
      final idToken = await _ensureAuthenticatedCall();
      return await _requestPaymentIntent(
        idToken: idToken,
        amountInCents: amountInCents,
        currency: currency,
        nutritionistUserId: nutritionistUserId,
      );
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
        '[AppointmentPaymentService] Callable cita falló: ${e.code} - ${e.message}',
      );
      if (e.code == 'unauthenticated') {
        return _retryAuthenticatedRequest(
          amountInCents: amountInCents,
          currency: currency,
          nutritionistUserId: nutritionistUserId,
        );
      }
      throw AppointmentPaymentFailure(
        friendlyErrorMessage(
          e,
          fallback:
              'No se pudo preparar el pago de la cita. Inténtalo nuevamente.',
        ),
      );
    }
  }

  Future<AppointmentPaymentIntentResult> _retryAuthenticatedRequest({
    required int amountInCents,
    required String currency,
    required String nutritionistUserId,
  }) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      final idToken = await _ensureAuthenticatedCall();
      return await _requestPaymentIntent(
        idToken: idToken,
        amountInCents: amountInCents,
        currency: currency,
        nutritionistUserId: nutritionistUserId,
      );
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
        '[AppointmentPaymentService] Reintento cita falló: ${e.code} - ${e.message}',
      );
      if (e.code == 'unauthenticated') {
        throw const AppointmentPaymentFailure(
          'Tu sesión no está activa. Cierra sesión e ingresa nuevamente.',
        );
      }
      throw AppointmentPaymentFailure(
        friendlyErrorMessage(
          e,
          fallback:
              'No se pudo preparar el pago de la cita. Inténtalo nuevamente.',
        ),
      );
    }
  }

  Future<AppointmentPaymentIntentResult> _requestPaymentIntent({
    required String idToken,
    required int amountInCents,
    required String currency,
    required String nutritionistUserId,
  }) async {
    final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
    final callable = functions.httpsCallable(
      'createAppointmentPaymentIntentHttp',
    );

    debugPrint(
      '[AppointmentPaymentService] Monto cita enviado: $amountInCents centavos',
    );

    final result = await callable.call(<String, dynamic>{
      'amount': amountInCents,
      'amountInCents': amountInCents,
      'currency': currency,
      'idToken': idToken,
      'nutritionistUserId': nutritionistUserId,
    });

    final responseData = Map<String, dynamic>.from(result.data as Map);
    final clientSecret = responseData['clientSecret'] as String?;
    final paymentIntentId = responseData['paymentIntentId'] as String?;

    if (clientSecret == null || clientSecret.isEmpty) {
      throw const AppointmentPaymentFailure(
        'No se recibió el clientSecret del pago.',
      );
    }

    return AppointmentPaymentIntentResult(
      clientSecret: clientSecret,
      paymentIntentId: paymentIntentId,
    );
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
      throw AppointmentPaymentFailure(_friendlyStripeMessage(e));
    } on PlatformException catch (e) {
      throw AppointmentPaymentFailure(_friendlyPlatformPaymentMessage(e));
    } catch (e) {
      throw AppointmentPaymentFailure(_friendlyGenericPaymentMessage(e));
    }
  }

  String _friendlyStripeMessage(StripeException error) {
    final rawMessage = error.error.localizedMessage?.trim();
    final normalized = '${error.error.code.name} ${rawMessage ?? ''}'
        .toLowerCase();

    if (_isCanceledPaymentMessage(normalized)) {
      return 'Pago cancelado. No se agendó ninguna cita.';
    }

    return rawMessage?.isNotEmpty == true
        ? rawMessage!
        : 'No se pudo completar el pago. Inténtalo nuevamente.';
  }

  String _friendlyPlatformPaymentMessage(PlatformException error) {
    final normalized = '${error.code} ${error.message ?? ''}'.toLowerCase();

    if (_isCanceledPaymentMessage(normalized)) {
      return 'Pago cancelado. No se agendó ninguna cita.';
    }

    return friendlyErrorMessage(
      error,
      fallback: 'No se pudo completar el pago. Inténtalo nuevamente.',
    );
  }

  String _friendlyGenericPaymentMessage(Object error) {
    final normalized = error.toString().toLowerCase();

    if (_isCanceledPaymentMessage(normalized)) {
      return 'Pago cancelado. No se agendó ninguna cita.';
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
