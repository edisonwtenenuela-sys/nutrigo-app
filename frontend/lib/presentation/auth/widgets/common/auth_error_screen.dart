import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/auth/controllers/auth_session_controller.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';
import 'package:emprendedor/presentation/shared/widgets/common/logout_dialog.dart';

class AuthErrorScreen extends StatelessWidget {
  const AuthErrorScreen({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  Future<void> _handleLogout(BuildContext context) async {
    final sessionController = AuthSessionController();
    final confirm = await showLogoutDialog(context, role: AppFeedbackRole.auth);

    if (!confirm) return;

    await sessionController.signOutOnly();
  }

  Widget _buildRetryButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton.icon(
        onPressed: onRetry,
        icon: Icon(Icons.refresh_rounded, size: 20.sp),
        label: Text(
          'Reintentar',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return TextButton(
      onPressed: () => _handleLogout(context),
      child: Text(
        'Cerrar sesión',
        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = RoleTheme.client;

    return Scaffold(
      backgroundColor: palette.background,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 70.sp,
                color: RoleTheme.iconColorFor(Icons.error_outline_rounded),
              ),
              SizedBox(height: 16.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: palette.text,
                ),
              ),
              SizedBox(height: 20.h),
              _buildRetryButton(),
              SizedBox(height: 12.h),
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }
}