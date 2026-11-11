import 'package:flutter_test/flutter_test.dart';

import 'package:emprendedor/features/auth/helpers/register_validators.dart';

void main() {
  group('RegisterValidators.email', () {
    test('rejects empty and malformed emails', () {
      expect(RegisterValidators.email(''), isNotNull);
      expect(RegisterValidators.email('cliente'), isNotNull);
      expect(RegisterValidators.email('cliente@correo'), isNotNull);
    });

    test('rejects common .con typo with a clear suggestion', () {
      final error = RegisterValidators.email('cliente@hotmail.con');

      expect(error, isNotNull);
      expect(error, contains('hotmail.com'));
    });

    test('allows valid international domains such as .es', () {
      expect(RegisterValidators.email('cliente@correo.es'), isNull);
      expect(RegisterValidators.email('cliente@correo.com'), isNull);
    });
  });

  group('RegisterValidators.password', () {
    test('requires a strong password', () {
      expect(RegisterValidators.password('abc123'), isNotNull);
      expect(RegisterValidators.password('Abcdef12'), isNotNull);
      expect(RegisterValidators.password('Abcdef12!'), isNull);
    });
  });

  group('RegisterValidators.confirmPassword', () {
    test('rejects mismatched passwords', () {
      expect(
        RegisterValidators.confirmPassword('Abcdef12!', 'Otra12!'),
        'Las contraseñas no coinciden.',
      );
    });

    test('allows matching passwords', () {
      expect(
        RegisterValidators.confirmPassword('Abcdef12!', 'Abcdef12!'),
        isNull,
      );
    });
  });
}
