class BusinessProfileFormValidators {
  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 10) {
      return 'Ingresa 10 dígitos para el celular';
    }
    return null;
  }

  static String? document({
    required String? value,
    required String documentType,
  }) {
    final cleaned = (value ?? '').replaceAll(RegExp(r'\D'), '');
    final expectedLength = documentType == 'ruc' ? 13 : 10;

    if (cleaned.isEmpty) {
      return 'Este campo es obligatorio';
    }

    if (cleaned.length != expectedLength) {
      return documentType == 'ruc'
          ? 'El RUC debe tener 13 dígitos'
          : 'La cédula debe tener 10 dígitos';
    }

    return null;
  }
}








