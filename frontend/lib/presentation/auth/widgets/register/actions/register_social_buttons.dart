import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/auth/widgets/common/auth_google_button.dart';

class RegisterSocialButtons extends StatelessWidget {
  final String selectedRole;
  final bool isLoading;
  final VoidCallback onGoogleRegister;
  final VoidCallback onPhoneRegister;
  final VoidCallback onLogin;

  const RegisterSocialButtons({
    super.key,
    required this.selectedRole,
    required this.isLoading,
    required this.onGoogleRegister,
    required this.onPhoneRegister,
    required this.onLogin,
  });

  RolePalette get _palette {
    switch (selectedRole) {
      case 'cliente':
        return RoleTheme.client;
      case 'nutricionista':
        return RoleTheme.nutritionist;
      case 'emprendedor':
      default:
        return RoleTheme.entrepreneur;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(color: palette.primary.withValues(alpha: 0.15)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                'o continúa con',
                style: TextStyle(
                  color: palette.mutedText,
                  fontSize: 11.7.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: palette.primary.withValues(alpha: 0.15)),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        AuthGoogleButton(
          label: 'Continuar con Google',
          onPressed: isLoading ? null : onGoogleRegister,
          palette: palette,
          height: 45.h,
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          height: 45.h,
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : onPhoneRegister,
            icon: Icon(
              Icons.phone_iphone_rounded,
              color: RoleTheme.iconColorFor(
                Icons.phone_iphone_rounded,
                fallback: palette.primary,
              ),
              size: 18.sp,
            ),
            label: Text(
              'Continuar con teléfono',
              style: TextStyle(
                fontSize: 12.8.sp,
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
                borderRadius: BorderRadius.circular(15.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 7.h),
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
          ),
          onPressed: isLoading ? null : onLogin,
          child: Text(
            '¿Ya tienes una cuenta? Inicia sesión',
            style: TextStyle(
              color: palette.text,
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        _RegisterTrustFooter(palette: palette),
      ],
    );
  }
}

class _RegisterTrustFooter extends StatelessWidget {
  final RolePalette palette;

  const _RegisterTrustFooter({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: palette.surface.withValues(alpha: 0.32),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TrustItem(
            icon: Icons.verified_user_outlined,
            label: 'Seguro',
            palette: palette,
          ),
          _TrustDivider(palette: palette),
          _TrustItem(
            icon: Icons.lock_outline_rounded,
            label: 'Privado',
            palette: palette,
          ),
          _TrustDivider(palette: palette),
          _TrustItem(
            icon: Icons.check_circle_outline_rounded,
            label: 'Confiable',
            palette: palette,
          ),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final RolePalette palette;

  const _TrustItem({
    required this.icon,
    required this.label,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
          size: 14.sp,
        ),
        SizedBox(width: 5.w),
        Text(
          label,
          style: TextStyle(
            color: palette.text.withValues(alpha: 0.78),
            fontSize: 10.6.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _TrustDivider extends StatelessWidget {
  final RolePalette palette;

  const _TrustDivider({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.w,
      height: 16.h,
      color: palette.primary.withValues(alpha: 0.10),
    );
  }
}