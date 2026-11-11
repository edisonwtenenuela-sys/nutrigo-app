import 'package:flutter/material.dart';

import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

void showBusinessStatusDialog(
    BuildContext context, {
      required String title,
      required String message,
      required IconData icon,
    }) {
  final type = switch (icon) {
    Icons.cancel_rounded => AppFeedbackType.error,
    Icons.pending_actions_rounded => AppFeedbackType.warning,
    _ => AppFeedbackType.success,
  };

  showAppMessage(
    context,
    role: AppFeedbackRole.entrepreneur,
    type: type,
    title: title,
    message: message,
  );
}