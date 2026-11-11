import 'package:flutter/services.dart';

class ProfessionalRegistryUtils {
  static const String msp = 'msp';
  static const String acess = 'acess';
  static const String senescyt = 'senescyt';

  /// Valor usado por versiones anteriores. Se mantiene para leer datos guardados.
  static const String mspAcess = 'msp_acess';

  static const List<String> registryTypes = [msp, acess, senescyt];

  static const List<String> specialtyOptions = [
    'Nutrición clínica',
    'Nutrición deportiva',
    'Nutrición infantil',
    'Nutrición materno-infantil',
    'Nutrición geriátrica',
    'Control de peso',
    'Educación alimentaria',
    'Dietoterapia',
    'Otra',
  ];

  static String normalizeRegistryType(String? value) {
    final cleanValue = value?.trim() ?? '';
    if (cleanValue == mspAcess) return msp;
    if (registryTypes.contains(cleanValue)) return cleanValue;
    return msp;
  }

  static String registryTypeLabel(String value) {
    switch (value) {
      case msp:
        return 'MSP';
      case acess:
        return 'ACESS';
      case mspAcess:
        return 'MSP / ACESS';
      case senescyt:
        return 'SENESCYT';
      default:
        return 'Selecciona el tipo de registro';
    }
  }

  static String registryFieldLabel(String type) {
    switch (type) {
      case msp:
        return 'Cédula MSP';
      case acess:
        return 'Registro ACESS';
      case senescyt:
        return 'Registro SENESCYT';
      default:
        return 'Registro profesional';
    }
  }

  static String registryHint(String type) {
    switch (type) {
      case msp:
        return 'Ingresa 9 dígitos de tu cédula';
      case acess:
        return 'Ej: ABC123456';
      case senescyt:
        return 'Ej: 1040-15-1409665';
      default:
        return 'Ingresa tu registro profesional';
    }
  }

  static List<TextInputFormatter> licenseInputFormatters(String type) {
    switch (type) {
      case msp:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ];
      case acess:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
          LengthLimitingTextInputFormatter(9),
        ];
      case senescyt:
        return [SenescytLicenseInputFormatter()];
      default:
        return const [];
    }
  }

  static String? validateRegistryType(String? value) {
    if (value == null || !registryTypes.contains(value)) {
      return 'Selecciona el tipo de registro.';
    }

    return null;
  }

  static String? validateProfessionalLicense({
    required String? registryType,
    required String? value,
  }) {
    final cleanRegistryType = normalizeRegistryType(registryType);
    final cleaned = (value ?? '').trim();

    if (cleaned.isEmpty) return 'Ingresa tu registro profesional.';

    if (cleanRegistryType == senescyt) {
      final isValid = RegExp(r'^\d{4}-\d{2}-\d{5,7}$').hasMatch(cleaned);
      return isValid ? null : 'Usa el formato 0000-00-0000000.';
    }

    if (cleanRegistryType == msp) {
      final isValid = RegExp(r'^\d{9}$').hasMatch(cleaned);
      return isValid ? null : 'Ingresa 9 dígitos para el registro MSP.';
    }

    if (cleanRegistryType == acess) {
      final isValid = RegExp(r'^[a-zA-Z0-9]{9}$').hasMatch(cleaned);
      return isValid ? null : 'Ingresa 9 caracteres alfanuméricos para ACESS.';
    }

    return 'Selecciona el tipo de registro.';
  }
}

class SenescytLicenseInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 13 ? digits.substring(0, 13) : digits;
    final buffer = StringBuffer();

    for (var index = 0; index < limited.length; index++) {
      if (index == 4 || index == 6) buffer.write('-');
      buffer.write(limited[index]);
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}








