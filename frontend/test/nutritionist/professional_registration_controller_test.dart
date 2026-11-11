import 'package:emprendedor/features/nutritionist/controllers/nutritionist_professional_registration_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NutritionistProfessionalRegistrationController validators', () {
    test('requiredFieldValue rejects empty values', () {
      expect(
        NutritionistProfessionalRegistrationController.requiredFieldValue(''),
        'Campo obligatorio',
      );
      expect(
        NutritionistProfessionalRegistrationController.requiredFieldValue(
          ' Ana ',
        ),
        isNull,
      );
    });

    test('validatePhoneValue requires 10 digits', () {
      expect(
        NutritionistProfessionalRegistrationController.validatePhoneValue(''),
        'Campo obligatorio',
      );
      expect(
        NutritionistProfessionalRegistrationController.validatePhoneValue(
          '099',
        ),
        'Ingresa 10 dígitos para el celular',
      );
      expect(
        NutritionistProfessionalRegistrationController.validatePhoneValue(
          '0999999999',
        ),
        isNull,
      );
    });

    test('validateDescriptionValue requires a meaningful description', () {
      expect(
        NutritionistProfessionalRegistrationController.validateDescriptionValue(
          '',
        ),
        'Campo obligatorio',
      );
      expect(
        NutritionistProfessionalRegistrationController.validateDescriptionValue(
          'Muy corta',
        ),
        'Describe un poco más tu experiencia',
      );
      expect(
        NutritionistProfessionalRegistrationController.validateDescriptionValue(
          'Nutricionista clínica con experiencia en atención integral.',
        ),
        isNull,
      );
    });
  });
}
