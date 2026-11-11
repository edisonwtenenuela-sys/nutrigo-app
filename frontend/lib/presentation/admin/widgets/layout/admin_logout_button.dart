import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/auth/controllers/auth_session_controller.dart';
import 'package:emprendedor/presentation/auth/pages/auth_landing_page.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class AdminLogoutButton extends StatelessWidget {
  AdminLogoutButton({super.key});

  final AuthSessionController _sessionController = AuthSessionController();

  Future<void> _logout(BuildContext context) async {
    final confirm = await showAppConfirm(
      context,
      role: AppFeedbackRole.admin,
      type: AppFeedbackType.warning,
      title: 'Cerrar sesión',
      message: '¿Seguro que deseas salir del panel administrativo?',
      confirmText: 'Salir',
      cancelText: 'Cancelar',
    );

    if (!confirm) return;

    if (!context.mounted) return;
    final signOutFuture = _sessionController.signOutOnly();
    AppNavigator.replaceAll(context, const AuthLandingPage());

    await signOutFuture;
  }

  Widget _buildIcon(RolePalette palette) {
    return Icon(Icons.logout_rounded, size: 23.sp, color: palette.text);
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.admin;

    return IconButton(
      tooltip: 'Cerrar sesión',
      onPressed: () => _logout(context),
      icon: _buildIcon(palette),
    );
  }
}
