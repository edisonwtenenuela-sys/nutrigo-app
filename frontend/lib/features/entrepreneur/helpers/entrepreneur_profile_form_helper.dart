import 'package:flutter/services.dart';

class BusinessProfileFormHelper {
  static int documentMaxLength(String documentType) {
    return documentType == 'ruc' ? 13 : 10;
  }

  static List<TextInputFormatter> documentFormatters(String documentType) {
    return [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(documentMaxLength(documentType)),
    ];
  }

  static String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  static String? phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 10) {
      return 'Ingresa 10 dígitos para el celular';
    }

    return null;
  }

  static String? documentValidator({
    required String? value,
    required String documentType,
  }) {
    final cleaned = (value ?? '').replaceAll(RegExp(r'\D'), '');
    final expectedLength = documentMaxLength(documentType);

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

  static String localEcuadorPhone(String? value) {
    final raw = value?.trim() ?? '';
    final digits = raw.replaceAll(RegExp(r'\D'), '');

    if (raw.startsWith('+593') && digits.length == 12) {
      return '0${digits.substring(3)}';
    }

    if (digits.startsWith('593') && digits.length == 12) {
      return '0${digits.substring(3)}';
    }

    return digits.length <= 10 ? digits : raw;
  }
}








