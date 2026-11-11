import 'package:emprendedor/features/nutritionist/controllers/nutritionist_profile_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NutritionistProfileSaveResult', () {
    test('fromControllerState returns success message', () {
      final result = NutritionistProfileSaveResult.fromControllerState(
        success: true,
      );

      expect(result.success, isTrue);
      expect(result.requiresAuthRedirect, isFalse);
      expect(
        result.message,
        'Tu información profesional se actualizó correctamente.',
      );
    });

    test('fromControllerState preserves generic error message', () {
      final result = NutritionistProfileSaveResult.fromControllerState(
        success: false,
        errorMessage: 'Error al guardar perfil.',
      );

      expect(result.success, isFalse);
      expect(result.requiresAuthRedirect, isFalse);
      expect(result.message, 'Error al guardar perfil.');
    });

    test('fromControllerState marks auth redirect when session is missing', () {
      final result = NutritionistProfileSaveResult.fromControllerState(
        success: false,
        errorMessage: 'No hay usuario autenticado.',
      );

      expect(result.success, isFalse);
      expect(result.requiresAuthRedirect, isTrue);
    });
  });
}
