import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/auth/helpers/register_role_helper.dart';
import 'package:emprendedor/presentation/auth/widgets/common/index.dart';
import 'package:emprendedor/presentation/auth/widgets/register/form/register_form_field.dart';
import 'package:emprendedor/presentation/auth/widgets/register/form/register_role_selector.dart';
import 'package:emprendedor/presentation/auth/widgets/register/form/register_terms_text.dart';

class RegisterFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController ageController;
  final TextEditingController dietaryGoalController;
  final TextEditingController documentNumberController;
  final String documentType;
  final TextEditingController businessDescriptionController;
  final TextEditingController specialtyController;
  final TextEditingController licenseNumberController;
  final TextEditingController professionalDescriptionController;
  final String selectedRole;
  final bool isLoading;
  final TapGestureRecognizer termsRecognizer;
  final TapGestureRecognizer privacyRecognizer;
  final Function(String role) onRoleChanged;
  final ValueChanged<String> onDocumentTypeChanged;
  final VoidCallback onRegister;
  final VoidCallback onClearError;
  final String? Function(String?) validateEmail;
  final String? Function(String?) validatePassword;
  final String? Function(String?) validateConfirmPassword;
  final String? Function(String?) validateRequired;
  final String? Function(String?) validatePhone;
  final String? Function(String?) validateAge;
  final String? Function(String?) validateDocument;
  final String? Function(String?) validateLicenseNumber;

  const RegisterFormCard({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.ageController,
    required this.dietaryGoalController,
    required this.documentNumberController,
    required this.documentType,
    required this.businessDescriptionController,
    required this.specialtyController,
    required this.licenseNumberController,
    required this.professionalDescriptionController,
    required this.selectedRole,
    required this.isLoading,
    required this.termsRecognizer,
    required this.privacyRecognizer,
    required this.onRoleChanged,
    required this.onDocumentTypeChanged,
    required this.onRegister,
    required this.onClearError,
    required this.validateEmail,
    required this.validatePassword,
    required this.validateConfirmPassword,
    required this.validateRequired,
    required this.validatePhone,
    required this.validateAge,
    required this.validateDocument,
    required this.validateLicenseNumber,
  });

  RolePalette get _palette => RegisterRoleHelper.palette(selectedRole);

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    final actionColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 15.h),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(
          color: palette.surface.withValues(alpha: 0.70),
        ),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 30.r,
            offset: Offset(0, 16.h),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RegisterAccountTypeHeader(palette: palette),
            SizedBox(height: 10.h),
            RegisterRoleSelector(
              selectedRole: selectedRole,
              isLoading: isLoading,
              onRoleChanged: onRoleChanged,
            ),
            SizedBox(height: 12.h),
            RegisterFormField(
              controller: emailController,
              label: 'Correo electrónico',
              icon: Icons.alternate_email_rounded,
              validator: validateEmail,
              enabled: !isLoading,
              palette: palette,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => onClearError(),
            ),
            SizedBox(height: 9.h),
            PasswordVisibilityField(
              controller: passwordController,
              label: 'Contraseña',
              icon: Icons.lock_rounded,
              validator: validatePassword,
              palette: palette,
              enabled: !isLoading,
              onChanged: (_) => onClearError(),
            ),
            SizedBox(height: 6.h),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: passwordController,
              builder: (context, value, _) {
                if (value.text.trim().isEmpty) return const SizedBox.shrink();
                return Column(
                  children: [
                    PasswordStrengthMeter(
                      password: value.text,
                      palette: palette,
                    ),
                    SizedBox(height: 7.h),
                  ],
                );
              },
            ),
            PasswordVisibilityField(
              controller: confirmPasswordController,
              label: 'Confirmar contraseña',
              icon: Icons.lock_reset_rounded,
              validator: validateConfirmPassword,
              palette: palette,
              enabled: !isLoading,
              onChanged: (_) => onClearError(),
            ),
            PasswordMatchHint(
              passwordController: passwordController,
              confirmPasswordController: confirmPasswordController,
              palette: palette,
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onRegister,
                icon: isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Icon(
                        Icons.person_add_alt_1_rounded,
                        color: RoleTheme.iconColorFor(
                          Icons.person_add_alt_1_rounded,
                        ),
                        size: 19.sp,
                      ),
                label: Text(
                  isLoading ? 'Creando cuenta...' : 'Crear cuenta',
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: actionColor,
                  disabledBackgroundColor: palette.primary.withValues(
                    alpha: 0.35,
                  ),
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.72),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            RegisterTermsText(
              selectedRole: selectedRole,
              termsRecognizer: termsRecognizer,
              privacyRecognizer: privacyRecognizer,
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterAccountTypeHeader extends StatelessWidget {
  final RolePalette palette;

  const _RegisterAccountTypeHeader({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(
            Icons.manage_accounts_rounded,
            color: RoleTheme.iconColorFor(
              Icons.manage_accounts_rounded,
              fallback: palette.primary,
            ),
            size: 20.sp,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tipo de cuenta',
                style: TextStyle(
                  color: palette.text,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Elige cómo usarás la plataforma.',
                style: TextStyle(
                  color: palette.mutedText,
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}




