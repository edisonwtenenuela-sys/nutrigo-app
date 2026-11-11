import 'package:emprendedor/features/client/controllers/client_profile_edit_controller.dart';
import 'package:emprendedor/features/entrepreneur/controllers/business_profile_edit_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClientProfileEditController', () {
    test('validateEmailValue requires a valid contact email', () {
      expect(
        ClientProfileEditController.validateEmailValue(''),
        'Ingresa tu correo electr\u00f3nico',
      );
      expect(
        ClientProfileEditController.validateEmailValue('correo-malo'),
        'Ingresa un correo v\u00e1lido',
      );
      expect(
        ClientProfileEditController.validateEmailValue('cliente@example.com'),
        isNull,
      );
    });
  });

  group('BusinessProfileEditFeedback', () {
    test('title maps feedback types to presentation titles', () {
      expect(
        const BusinessProfileEditFeedback(
          message: 'ok',
          type: BusinessProfileEditFeedbackType.success,
        ).title,
        'Perfil guardado',
      );
      expect(
        const BusinessProfileEditFeedback(
          message: 'warn',
          type: BusinessProfileEditFeedbackType.warning,
        ).title,
        'Atenci\u00f3n',
      );
      expect(
        const BusinessProfileEditFeedback(
          message: 'info',
          type: BusinessProfileEditFeedbackType.info,
        ).title,
        'Informaci\u00f3n',
      );
    });
  });

  group('BusinessProfileEditController', () {
    test('validateEmailValue requires valid contact email', () {
      expect(
        BusinessProfileEditController.validateEmailValue(''),
        'Campo obligatorio',
      );
      expect(
        BusinessProfileEditController.validateEmailValue('correo-malo'),
        'Ingresa un correo v\u00e1lido',
      );
      expect(
        BusinessProfileEditController.validateEmailValue('negocio@example.com'),
        isNull,
      );
    });
  });
}
