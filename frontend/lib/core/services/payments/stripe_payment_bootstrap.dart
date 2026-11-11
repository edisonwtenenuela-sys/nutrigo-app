import 'package:flutter_stripe/flutter_stripe.dart';

class StripePaymentBootstrap {
  StripePaymentBootstrap._();

  static const String _publishableKey =
      String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

  static bool _isInitialized = false;
  static Future<void>? _pendingInitialization;

  static Future<void> ensureInitialized() {
    if (_isInitialized) {
      return Future<void>.value();
    }

    final pending = _pendingInitialization;
    if (pending != null) {
      return pending;
    }

    _pendingInitialization = _initialize();
    return _pendingInitialization!;
  }

  static Future<void> _initialize() async {
    try {
      if (_publishableKey.isEmpty) {
        throw StateError(
          'Falta STRIPE_PUBLISHABLE_KEY. Ejecuta Flutter con '
          '--dart-define=STRIPE_PUBLISHABLE_KEY=replace_with_test_publishable_key.',
        );
      }
      Stripe.publishableKey = _publishableKey;
      await Stripe.instance.applySettings();
      _isInitialized = true;
    } finally {
      if (!_isInitialized) {
        _pendingInitialization = null;
      }
    }
  }
}








