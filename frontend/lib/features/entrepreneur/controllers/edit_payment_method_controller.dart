import 'package:flutter/material.dart';

import 'package:emprendedor/data/models/entrepreneur/payments/payment_method_model.dart';

class EditPaymentMethodController {
  EditPaymentMethodController({required this.item})
    : detailController = TextEditingController(text: _initialDetailText(item));

  final PaymentMethodModel item;
  final TextEditingController detailController;

  PaymentMethodModel buildUpdatedItem() {
    return item.copyWith(
      details: {'descripcion': detailController.text.trim()},
    );
  }

  void dispose() {
    detailController.dispose();
  }

  static String _initialDetailText(PaymentMethodModel item) {
    final details = item.details;
    if (details == null) return '';

    return details['descripcion']?.toString() ??
        details['description']?.toString() ??
        details['descripción']?.toString() ??
        details['detalle']?.toString() ??
        '';
  }
}








