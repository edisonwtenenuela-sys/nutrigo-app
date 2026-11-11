import 'package:flutter/material.dart';

import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

Future<bool> showDeletePromotionDialog({
  required BuildContext context,
  required String promotionName,
}) {
  final name = promotionName.trim();
  final displayName = name.isNotEmpty ? '"$name"' : 'esta promoción';

  return showAppConfirm(
    context,
    role: AppFeedbackRole.entrepreneur,
    type: AppFeedbackType.warning,
    title: 'Eliminar promoción',
    message: '¿Seguro que deseas eliminar $displayName?',
    confirmText: 'Eliminar',
    cancelText: 'Cancelar',
  );
}