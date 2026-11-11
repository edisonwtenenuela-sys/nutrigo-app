import 'package:flutter/material.dart';

import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

const _logoutDialogTitle = 'Cerrar sesión';
const _logoutDialogMessage = '¿Quieres salir de tu cuenta?';
const _logoutConfirmText = 'Salir';
const _logoutCancelText = 'Cancelar';

Future<bool> showLogoutDialog(
    BuildContext context, {
      AppFeedbackRole role = AppFeedbackRole.auth,
    }) async {
  return showAppConfirm(
    context,
    role: role,
    type: AppFeedbackType.warning,
    title: _logoutDialogTitle,
    message: _logoutDialogMessage,
    confirmText: _logoutConfirmText,
    cancelText: _logoutCancelText,
  );
}