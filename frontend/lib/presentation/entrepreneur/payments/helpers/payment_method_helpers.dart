import 'package:flutter/material.dart';
import 'package:emprendedor/data/models/entrepreneur/payments/payment_method_model.dart';

class PaymentMethodHelpers {
  static IconData icon(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return Icons.money;
      case PaymentType.online:
        return Icons.payment;
    }
  }

  static String defaultDescription(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return 'Pago directo al recibir el pedido';
      case PaymentType.online:
        return 'Pago procesado mediante Stripe';
    }
  }

  static String creationDescription(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return 'Pago en efectivo';
      case PaymentType.online:
        return 'Pago en línea mediante Stripe';
    }
  }

  static String formatDetails(PaymentMethodModel item) {
    final details = item.details;

    if (details == null || details.isEmpty) {
      return defaultDescription(item.type);
    }

    final description = _firstNonEmptyDetail(details, [
      'descripcion',
      'description',
      'descripción',
      'detalle',
    ]);

    if (description != null) return description;

    final formatted = details.entries
        .where((entry) => entry.value.toString().trim().isNotEmpty)
        .map((entry) {
      final key = entry.key.replaceAll('_', ' ');
      final formattedKey = key.isEmpty
          ? key
          : '${key[0].toUpperCase()}${key.substring(1)}';

      return '$formattedKey: ${entry.value}';
    })
        .join('\n');

    return formatted.isEmpty ? defaultDescription(item.type) : formatted;
  }

  static String? _firstNonEmptyDetail(
      Map<String, dynamic> details,
      List<String> keys,
      ) {
    for (final key in keys) {
      final value = details[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }

    return null;
  }
}