import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/auth/controllers/auth_session_controller.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';
import 'package:emprendedor/presentation/auth/pages/auth_landing_page.dart';
import 'package:emprendedor/presentation/entrepreneur/payments/pages/payment_methods_page.dart';
import 'package:emprendedor/presentation/entrepreneur/profile/pages/index.dart';
import 'package:emprendedor/presentation/entrepreneur/social/pages/social_media_page.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';
import 'package:emprendedor/presentation/shared/widgets/common/logout_dialog.dart';

final Logger logger = Logger('SettingsPage');

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final AuthSessionController _sessionController = AuthSessionController();

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showLogoutDialog(
      context,
      role: AppFeedbackRole.entrepreneur,
    );

    if (!shouldLogout || !context.mounted) return;

    try {
      final logoutFuture = _sessionController.logout(context);
      AppNavigator.replaceAll(context, const AuthLandingPage());

      await logoutFuture;
    } catch (e, stackTrace) {
      logger.severe('Error durante el logout', e, stackTrace);

      if (!context.mounted) return;

      await showAppMessage(
        context,
        role: AppFeedbackRole.entrepreneur,
        type: AppFeedbackType.error,
        title: 'No se pudo salir',
        message: 'Error al cerrar sesión. Inténtalo nuevamente.',
      );
    }
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.04),
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, size: 22.sp),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.text,
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: palette.mutedText,
          size: 16.sp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;
    final userId = _sessionController.currentUserId();

    if (userId == null) {
      return Scaffold(
        backgroundColor: palette.background,
        body: Center(
          child: Text(
            'Usuario no autenticado.',
            style: TextStyle(
              color: palette.text,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        surfaceTintColor: palette.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Configuración',
          style: TextStyle(
            color: palette.text,
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: ListView(
          children: [
            _buildOptionTile(
              icon: Icons.edit_rounded,
              color: RoleTheme.iconValidation,
              title: 'Editar perfil',
              onTap: () {
                context.read<ProfileController>().setUserId(userId);

                AppNavigator.push(
                  context,
                  BusinessProfileEditPage(userId: userId),
                );
              },
            ),
            _buildOptionTile(
              icon: Icons.public_rounded,
              color: RoleTheme.iconInfo,
              title: 'Redes sociales',
              onTap: () {
                context.read<SocialMediaController>().setUserId(userId);

                AppNavigator.push(context, const SocialMediaPage());
              },
            ),
            _buildOptionTile(
              icon: Icons.credit_card_rounded,
              color: palette.primary,
              title: 'Métodos de pago',
              onTap: () {
                context.read<PaymentMethodController>().setUserId(userId);

                AppNavigator.push(context, const PaymentMethodsPage());
              },
            ),
            SizedBox(height: 18.h),
            _buildOptionTile(
              icon: Icons.logout_rounded,
              color: RoleTheme.iconDanger,
              title: 'Cerrar sesión',
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
