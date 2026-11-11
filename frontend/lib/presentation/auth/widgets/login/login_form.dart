import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/auth/controllers/login_controller.dart';

class LoginForm extends StatelessWidget {
  final LoginController controller;
  final RolePalette palette;
  final bool adminOnly;
  final VoidCallback onLogin;
  final VoidCallback onResetPassword;

  const LoginForm({
    super.key,
    required this.controller,
    required this.palette,
    required this.adminOnly,
    required this.onLogin,
    required this.onResetPassword,
  });

  bool _isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 600;
  }

  BorderRadius _inputRadius(bool isTablet) {
    return BorderRadius.circular(isTablet ? 18.0 : 18.r);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final actionColor = Theme.of(context).colorScheme.primary;

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LoginCardHeader(palette: palette, adminOnly: adminOnly),
          SizedBox(height: isTablet ? 14.0 : 14.h),
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              context,
              'Correo electrónico',
              Icons.alternate_email_rounded,
            ),
            style: TextStyle(
              color: palette.text,
              fontSize: isTablet ? 15.0 : 15.sp,
              fontWeight: FontWeight.w700,
            ),
            validator: controller.validateEmail,
            onChanged: (_) => controller.clearError(),
          ),
          SizedBox(height: isTablet ? 10.0 : 10.h),
          TextFormField(
            controller: controller.passwordController,
            obscureText: controller.obscurePassword,
            enableSuggestions: false,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              if (!controller.isLoading) onLogin();
            },
            style: TextStyle(
              color: palette.text,
              fontSize: isTablet ? 15.0 : 15.sp,
              fontWeight: FontWeight.w700,
            ),
            decoration:
                _inputDecoration(
                  context,
                  'Contraseña',
                  Icons.lock_rounded,
                ).copyWith(
                  suffixIcon: IconButton(
                    onPressed: controller.togglePasswordVisibility,
                    tooltip: controller.obscurePassword
                        ? 'Mostrar contraseña'
                        : 'Ocultar contraseña',
                    icon: Icon(
                      controller.obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: isTablet ? 20.0 : 20.sp,
                      color: palette.mutedText,
                    ),
                  ),
                ),
            validator: controller.validatePassword,
            onChanged: (_) => controller.clearError(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: controller.isLoading ? null : onResetPassword,
              style: TextButton.styleFrom(
                foregroundColor: palette.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 4.0 : 4.w,
                  vertical: isTablet ? 8.0 : 8.h,
                ),
              ),
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  fontSize: isTablet ? 13.0 : 13.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          SizedBox(height: isTablet ? 10.0 : 12.h),
          SizedBox(
            width: double.infinity,
            height: isTablet ? 48.0 : 48.h,
            child: ElevatedButton.icon(
              onPressed: controller.isLoading ? null : onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: actionColor,
                foregroundColor: palette.surface,
                disabledBackgroundColor: palette.primary.withValues(
                  alpha: 0.35,
                ),
                disabledForegroundColor: palette.surface.withValues(
                  alpha: 0.72,
                ),
                elevation: 0,
                shadowColor: actionColor.withValues(alpha: 0.28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 18.0 : 18.r),
                ),
              ),
              icon: controller.isLoading
                  ? SizedBox(
                      width: isTablet ? 20.0 : 20.w,
                      height: isTablet ? 20.0 : 20.w,
                      child: CircularProgressIndicator(
                        color: palette.surface,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.login_rounded, size: isTablet ? 20.0 : 20.sp),
              label: Text(
                controller.isLoading ? 'Ingresando...' : 'Iniciar sesión',
                style: TextStyle(
                  fontSize: isTablet ? 15.0 : 15.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context,
    String label,
    IconData iconData,
  ) {
    final isTablet = _isTablet(context);
    final radius = _inputRadius(isTablet);

    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: TextStyle(
        color: palette.mutedText,
        fontSize: isTablet ? 13.0 : 13.sp,
        fontWeight: FontWeight.w800,
      ),
      errorMaxLines: 2,
      errorStyle: TextStyle(
        fontSize: isTablet ? 10.4 : 10.4.sp,
        fontWeight: FontWeight.w600,
        height: 1.18,
      ),
      prefixIcon: Padding(
        padding: EdgeInsets.only(left: isTablet ? 4.0 : 4.w),
        child: Icon(
          iconData,
          color: RoleTheme.iconColorFor(iconData, fallback: palette.primary),
          size: isTablet ? 20.0 : 20.sp,
        ),
      ),
      prefixIconConstraints: BoxConstraints(minWidth: isTablet ? 44.0 : 44.w),
      border: OutlineInputBorder(borderRadius: radius),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: palette.primary.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: palette.primary,
          width: isTablet ? 1.6 : 1.6.w,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: RoleTheme.iconDanger,
          width: isTablet ? 1.2 : 1.2.w,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: RoleTheme.iconDanger,
          width: isTablet ? 1.5 : 1.5.w,
        ),
      ),
      filled: true,
      fillColor: palette.surface.withValues(alpha: 0.82),
      contentPadding: EdgeInsets.symmetric(
        vertical: isTablet ? 10.0 : 11.h,
        horizontal: isTablet ? 14.0 : 14.w,
      ),
    );
  }
}

class _LoginCardHeader extends StatelessWidget {
  final RolePalette palette;
  final bool adminOnly;

  const _LoginCardHeader({required this.palette, required this.adminOnly});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final icon = adminOnly
        ? Icons.admin_panel_settings_rounded
        : Icons.shield_rounded;

    return Row(
      children: [
        Container(
          width: isTablet ? 42.0 : 42.w,
          height: isTablet ? 42.0 : 42.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isTablet ? 15.0 : 15.r),
            color: palette.primary.withValues(alpha: 0.10),
          ),
          child: Icon(
            icon,
            color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
            size: isTablet ? 22.0 : 22.sp,
          ),
        ),
        SizedBox(width: isTablet ? 12.0 : 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                adminOnly ? 'Panel administrativo' : 'Acceso seguro',
                style: TextStyle(
                  color: palette.text,
                  fontSize: isTablet ? 15.0 : 15.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: isTablet ? 2.0 : 2.h),
              Text(
                adminOnly
                    ? 'Solo cuentas con rol administrador.'
                    : 'Tus datos se validan antes de cargar tus módulos.',
                style: TextStyle(
                  color: palette.mutedText,
                  fontSize: isTablet ? 12.0 : 12.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
