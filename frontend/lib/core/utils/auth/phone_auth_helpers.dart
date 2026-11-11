import 'package:firebase_auth/firebase_auth.dart';

import 'package:emprendedor/core/utils/friendly_error_message.dart';

String phoneDigitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

String phoneVerificationFailedMessage(FirebaseAuthException exception) {
  switch (exception.code) {
    case 'invalid-phone-number':
      return 'El número de teléfono proporcionado no es válido.';
    case 'too-many-requests':
      return 'Se enviaron demasiadas solicitudes. Inténtalo más tarde.';
    case 'network-request-failed':
      return 'No hay conexión a internet. Revisa tu red e inténtalo nuevamente.';
    default:
      return friendlyErrorMessage(
        exception,
        fallback:
            'No se pudo enviar el código de verificación. Inténtalo nuevamente.',
      );
  }
}

String phoneSignInErrorMessage(FirebaseAuthException exception) {
  switch (exception.code) {
    case 'invalid-verification-code':
      return 'El código ingresado es inválido.';
    case 'session-expired':
      return 'El código ha expirado. Solicita uno nuevo.';
    case 'network-request-failed':
      return 'No hay conexión a internet. Revisa tu red e inténtalo nuevamente.';
    default:
      return friendlyErrorMessage(
        exception,
        fallback: 'No se pudo completar la operación.',
      );
  }
}
