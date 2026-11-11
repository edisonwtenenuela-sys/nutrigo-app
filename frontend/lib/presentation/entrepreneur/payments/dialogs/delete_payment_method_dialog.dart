import 'package:flutter/material.dart';

import 'package:emprendedor/data/models/entrepreneur/payments/payment_method_model.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

Future<bool> showDeletePaymentMethodDialog({
  required BuildContext context,
  required PaymentMethodModel item,
}) {
  return showAppConfirm(
    context,
    role: AppFeedbackRole.entrepreneur,
    type: AppFeedbackType.warning,
    title: 'Eliminar método',
    message: '¿Seguro que deseas eliminar "${item.type.label}"?',
    confirmText: 'Eliminar',
    cancelText: 'Cancelar',
  );
}