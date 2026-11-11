import 'package:flutter_test/flutter_test.dart';

import 'package:emprendedor/core/utils/professional_registry_utils.dart';

void main() {
  group('ProfessionalRegistryUtils', () {
    test('validates registry type', () {
      expect(
        ProfessionalRegistryUtils.validateRegistryType(
          ProfessionalRegistryUtils.msp,
        ),
        isNull,
      );
      expect(
        ProfessionalRegistryUtils.validateRegistryType(
          ProfessionalRegistryUtils.acess,
        ),
        isNull,
      );
      expect(
        ProfessionalRegistryUtils.validateRegistryType(
          ProfessionalRegistryUtils.senescyt,
        ),
        isNull,
      );
      expect(ProfessionalRegistryUtils.validateRegistryType('otro'), isNotNull);
    });

    test('normalizes legacy MSP/ACESS registry type to MSP', () {
      expect(
        ProfessionalRegistryUtils.normalizeRegistryType(
          ProfessionalRegistryUtils.mspAcess,
        ),
        ProfessionalRegistryUtils.msp,
      );
    });

    test('validates SENESCYT license format', () {
      expect(
        ProfessionalRegistryUtils.validateProfessionalLicense(
          registryType: ProfessionalRegistryUtils.senescyt,
          value: '1040-15-1409665',
        ),
        isNull,
      );
      expect(
        ProfessionalRegistryUtils.validateProfessionalLicense(
          registryType: ProfessionalRegistryUtils.senescyt,
          value: '1040151409665',
        ),
        isNotNull,
      );
    });

    test('validates MSP registry as 9 numeric digits', () {
      expect(
        ProfessionalRegistryUtils.validateProfessionalLicense(
          registryType: ProfessionalRegistryUtils.msp,
          value: '123456789',
        ),
        isNull,
      );
      expect(
        ProfessionalRegistryUtils.validateProfessionalLicense(
          registryType: ProfessionalRegistryUtils.msp,
          value: '12345678A',
        ),
        isNotNull,
      );
      expect(
        ProfessionalRegistryUtils.validateProfessionalLicense(
          registryType: ProfessionalRegistryUtils.msp,
          value: '1234567890',
        ),
        isNotNull,
      );
    });

    test('validates ACESS registry as 9 alphanumeric characters', () {
      expect(
        ProfessionalRegistryUtils.validateProfessionalLicense(
          registryType: ProfessionalRegistryUtils.acess,
          value: 'AB1234567',
        ),
        isNull,
      );
      expect(
        ProfessionalRegistryUtils.validateProfessionalLicense(
          registryType: ProfessionalRegistryUtils.acess,
          value: 'ABC12345',
        ),
        isNotNull,
      );
      expect(
        ProfessionalRegistryUtils.validateProfessionalLicense(
          registryType: ProfessionalRegistryUtils.acess,
          value: 'ABC12345*',
        ),
        isNotNull,
      );
    });
  });
}
