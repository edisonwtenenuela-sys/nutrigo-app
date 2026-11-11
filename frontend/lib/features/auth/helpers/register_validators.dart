import 'package:emprendedor/features/auth/helpers/password_strength_helper.dart';

class RegisterValidators {
  const RegisterValidators._();

  static const Map<String, String> _commonDomainFixes = {
    'gmail.con': 'gmail.com',
    'hotmail.con': 'hotmail.com',
    'outlook.con': 'outlook.com',
    'yahoo.con': 'yahoo.com',
    'icloud.con': 'icloud.com',
    'live.con': 'live.com',
    'gmail.co': 'gmail.com',
    'hotmail.co': 'hotmail.com',
    'outlook.co': 'outlook.com',
    'yahoo.co': 'yahoo.com',
  };

  static String? email(String? value) {
    final email = value?.trim().toLowerCase() ?? '';

    if (email.isEmpty) {
      return 'Ingresa un correo válido.';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Ingresa un correo válido.';
    }

    final parts = email.split('@');
    if (parts.length != 2) {
      return 'Ingresa un correo válido.';
    }

    final domain = parts.last.trim();

    if (_commonDomainFixes.containsKey(domain)) {
      return 'Revisa el dominio. ¿Quisiste escribir ${_commonDomainFixes[domain]}?';
    }

    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Ingresa una contraseña.';
    }

    final strength = PasswordStrengthEvaluator.evaluate(password);

    if (!strength.hasMinLength) {
      return 'Debe tener mínimo 8 caracteres.';
    }

    if (!strength.hasUppercase ||
        !strength.hasLowercase ||
        !strength.hasNumber ||
        !strength.hasSymbol) {
      return 'Incluye mayúscula, minúscula, número y símbolo.';
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña.';
    }

    if (value != password) {
      return 'Las contraseñas no coinciden.';
    }

    return null;
  }

  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio.';
    }

    return null;
  }

  static String? phone(String? value) {
    final cleaned = (value ?? '').replaceAll(RegExp(r'\D'), '');

    if (cleaned.isEmpty) {
      return 'Ingresa un teléfono.';
    }

    if (cleaned.length != 10) {
      return 'Ingresa 10 dígitos para el celular.';
    }

    return null;
  }

  static String? age(String? value) {
    final age = int.tryParse((value ?? '').trim());

    if (age == null) {
      return 'Ingresa tu edad.';
    }

    if (age < 12 || age > 100) {
      return 'Ingresa una edad válida.';
    }

    return null;
  }

  static String? document(String? value, String documentType) {
    final cleaned = (value ?? '').replaceAll(RegExp(r'\D'), '');
    final expectedLength = documentType == 'ruc' ? 13 : 10;
    final label = documentType == 'ruc' ? 'RUC' : 'cédula';

    if (cleaned.isEmpty) {
      return 'Ingresa tu $label.';
    }

    if (cleaned.length != expectedLength) {
      return documentType == 'ruc'
          ? 'El RUC debe tener 13 dígitos.'
          : 'La cédula debe tener 10 dígitos.';
    }

    return null;
  }

  static String? licenseNumber(String? value) {
    final cleaned = (value ?? '').trim();

    if (cleaned.isEmpty) {
      return 'Ingresa tu registro profesional.';
    }

    if (cleaned.length < 6) {
      return 'Ingresa un registro profesional válido.';
    }

    return null;
  }

  static String? externalProviderProfileError({
    required String selectedRole,
    required String documentType,
    required String name,
    required String phoneNumber,
    required String address,
    required String ageValue,
    required String dietaryGoal,
    required String documentNumber,
    required String businessDescription,
    required String specialty,
    required String license,
    required String professionalDescription,
  }) {
    final validators = <String?>[
      requiredField(name),
      phone(phoneNumber),
      if (selectedRole == 'cliente') ...[
        age(ageValue),
        requiredField(address),
        requiredField(dietaryGoal),
      ],
      if (selectedRole == 'emprendedor') ...[
        document(documentNumber, documentType),
        requiredField(address),
        requiredField(businessDescription),
      ],
      if (selectedRole == 'nutricionista') ...[
        requiredField(specialty),
        licenseNumber(license),
        requiredField(professionalDescription),
      ],
    ];

    for (final error in validators) {
      if (error != null) return error;
    }

    return null;
  }
}








