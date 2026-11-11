import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:emprendedor/core/utils/auth/phone_auth_helpers.dart';

void main() {
  group('phoneDigitsOnly', () {
    test('keeps only numeric digits', () {
      expect(phoneDigitsOnly('+593 99-123-4567'), '593991234567');
    });
  });

  group('phoneVerificationFailedMessage', () {
    test('maps invalid phone number errors', () {
      final message = phoneVerificationFailedMessage(
        FirebaseAuthException(code: 'invalid-phone-number'),
      );

      expect(message, contains('teléfono'));
      expect(message, contains('válido'));
    });

    test('maps too many requests errors', () {
      final message = phoneVerificationFailedMessage(
        FirebaseAuthException(code: 'too-many-requests'),
      );

      expect(message, contains('demasiadas solicitudes'));
    });
  });

  group('phoneSignInErrorMessage', () {
    test('maps invalid verification code errors', () {
      final message = phoneSignInErrorMessage(
        FirebaseAuthException(code: 'invalid-verification-code'),
      );

      expect(message, contains('código'));
      expect(message, contains('inválido'));
    });

    test('maps expired sessions', () {
      final message = phoneSignInErrorMessage(
        FirebaseAuthException(code: 'session-expired'),
      );

      expect(message, contains('expirado'));
    });
  });
}
