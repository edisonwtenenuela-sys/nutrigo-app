import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

String friendlyErrorMessage(
  Object error, {
  String fallback = 'Ocurrió un problema. Inténtalo nuevamente.',
}) {
  if (error is FirebaseException) {
    return friendlyFirebaseMessage(error, fallback: fallback);
  }

  if (error is TimeoutException) {
    return 'La operación tardó demasiado. Revisa tu conexión e inténtalo nuevamente.';
  }

  if (error is PlatformException) {
    return _friendlyRawMessage(
      '${error.code} ${error.message ?? ''}',
      fallback: fallback,
    );
  }

  return _friendlyRawMessage(error.toString(), fallback: fallback);
}

String friendlyFirebaseMessage(
  FirebaseException error, {
  String fallback = 'Ocurrió un problema. Inténtalo nuevamente.',
}) {
  switch (error.code) {
    case 'unavailable':
    case 'network-request-failed':
      return 'No hay conexión con el servicio. Revisa tu internet e inténtalo nuevamente.';
    case 'deadline-exceeded':
      return 'La operación tardó demasiado. Revisa tu conexión e inténtalo nuevamente.';
    case 'permission-denied':
      return 'No tienes permisos para realizar esta acción.';
    case 'unauthenticated':
      return 'Tu sesión ha expirado. Inicia sesión nuevamente.';
    case 'resource-exhausted':
      return 'El servicio está ocupado en este momento. Inténtalo nuevamente en unos minutos.';
    case 'cancelled':
      return 'La operación fue cancelada. Inténtalo nuevamente.';
    case 'not-found':
      return 'No se encontró la información solicitada.';
    case 'already-exists':
      return 'La información ya existe.';
    case 'invalid-argument':
      return 'La información enviada no es válida. Revisa los datos e inténtalo nuevamente.';
    case 'internal':
      return 'El servicio presentó un problema interno. Inténtalo nuevamente.';
  }

  return _friendlyRawMessage(
    '${error.code} ${error.message ?? ''}',
    fallback: fallback,
  );
}

String _friendlyRawMessage(String raw, {required String fallback}) {
  final normalized = raw.toLowerCase();

  if (normalized.contains('unavailable') ||
      normalized.contains('network') ||
      normalized.contains('internet') ||
      normalized.contains('socket') ||
      normalized.contains('host lookup') ||
      normalized.contains('failed host lookup') ||
      normalized.contains('connection') ||
      normalized.contains('timeout') ||
      normalized.contains('deadline-exceeded')) {
    return 'No hay conexión con el servicio. Revisa tu internet e inténtalo nuevamente.';
  }

  if (normalized.contains('permission-denied') ||
      normalized.contains('permission denied') ||
      normalized.contains('insufficient permissions')) {
    return 'No tienes permisos para realizar esta acción.';
  }

  if (normalized.contains('unauthenticated') ||
      normalized.contains('requires-recent-login')) {
    return 'Tu sesión ha expirado. Inicia sesión nuevamente.';
  }

  return fallback;
}
