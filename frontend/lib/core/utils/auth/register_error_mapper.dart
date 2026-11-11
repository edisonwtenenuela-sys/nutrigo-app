import 'package:firebase_auth/firebase_auth.dart';

import 'package:emprendedor/core/utils/friendly_error_message.dart';

String registerEmailErrorMessage(FirebaseAuthException exception) {
  switch (exception.code) {
    case 'weak-password':
      return 'La contraseña es demasiado débil.';
    case 'email-already-in-use':
      return 'Esta cuenta ya está registrada. Por favor, inicia sesión.';
    case 'invalid-email':
      return 'El correo ingresado no es válido.';
    case 'network-request-failed':
      return 'No hay conexión a internet. Revisa tu red e inténtalo nuevamente.';
    default:
      return friendlyErrorMessage(
        exception,
        fallback: 'Error de registro. Inténtalo de nuevo.',
      );
  }
}

String registerGoogleErrorMessage(FirebaseAuthException exception) {
  switch (exception.code) {
    case 'account-exists-with-different-credential':
      return 'Ya existe una cuenta con este correo. Inicia sesión con tu método original.';
    case 'invalid-credential':
      return 'Credenciales de Google inválidas.';
    case 'network-request-failed':
      return 'No hay conexión a internet. Revisa tu red e inténtalo nuevamente.';
    default:
      return friendlyErrorMessage(
        exception,
        fallback: 'Error inesperado al registrar con Google.',
      );
  }
}
