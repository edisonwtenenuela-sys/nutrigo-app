import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/auth/controllers/login_controller.dart';
import 'package:emprendedor/presentation/auth/pages/phone_auth_page.dart';
import 'package:emprendedor/presentation/auth/pages/register_page.dart';
import 'package:emprendedor/presentation/auth/widgets/index.dart';

class LoginSocialButtons extends StatelessWidget {
  final LoginController controller;
  final VoidCallback onGoogleLogin;

  const LoginSocialButtons({
    super.key,
    required this.controller,
    required this.onGoogleLogin,
  });

  bool _isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 600;
  }

  void _goToPhoneLogin(BuildContext context) {
    AppNavigator.push(context, const PhoneAuthPage(isLogin: true));
  }

  void _goToRegister(BuildContext context) {
    AppNavigator.push(context, const RegisterPage());
  }

  Widget _buildPhoneButton({
    required BuildContext context,
    required bool isTablet,
    required RolePalette palette,
  }) {
    return SizedBox(
      width: double.infinity,
      height: isTablet ? 48.0 : 50.h,
      child: OutlinedButton.icon(
        onPressed: controller.isLoading ? null : () => _goToPhoneLogin(context),
        icon: Icon(
          Icons.phone_iphone_rounded,
          color: RoleTheme.iconColorFor(
            Icons.phone_iphone_rounded,
            fallback: palette.primary,
          ),
          size: isTablet ? 20.0 : 20.sp,
        ),
        label: Text(
          'Continuar con teléfono',
          style: TextStyle(
            fontSize: isTablet ? 14.0 : 14.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          backgroundColor: palette.surface.withValues(alpha: 0.74),
          side: BorderSide(
            color: palette.primary.withValues(alpha: 0.12),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 16.0 : 16.r),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    const palette = RoleTheme.client;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(color: palette.primary.withValues(alpha: 0.15)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 12.0 : 12.w),
              child: Text(
                'o continúa con',
                style: TextStyle(
                  color: palette.mutedText,
                  fontSize: isTablet ? 12.0 : 12.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: palette.primary.withValues(alpha: 0.15)),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 12.0 : 12.h),
        AuthGoogleButton(
          label: 'Continuar con Google',
          onPressed: controller.isLoading ? null : onGoogleLogin,
          palette: palette,
          height: isTablet ? 48.0 : 50.h,
        ),
        SizedBox(height: isTablet ? 10.0 : 10.h),
        _buildPhoneButton(
          context: context,
          isTablet: isTablet,
          palette: palette,
        ),
        SizedBox(height: isTablet ? 16.0 : 18.h),
        TextButton(
          onPressed: controller.isLoading ? null : () => _goToRegister(context),
          child: Text(
            '¿No tienes cuenta? Regístrate',
            style: TextStyle(
              color: palette.text,
              fontSize: isTablet ? 14.0 : 14.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}