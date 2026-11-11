import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class RegisterTermsText extends StatelessWidget {
  final String selectedRole;
  final TapGestureRecognizer termsRecognizer;
  final TapGestureRecognizer privacyRecognizer;

  const RegisterTermsText({
    super.key,
    required this.selectedRole,
    required this.termsRecognizer,
    required this.privacyRecognizer,
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

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          color: palette.mutedText,
          fontSize: 10.5.sp,
          height: 1.3,
          fontWeight: FontWeight.w600,
        ),
        children: [
          const TextSpan(
            text: 'Al registrarte aceptas nuestros ',
          ),
          TextSpan(
            text: 'Términos',
            recognizer: termsRecognizer,
            style: TextStyle(
              color: palette.primary,
              decoration: TextDecoration.underline,
              decorationColor: palette.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const TextSpan(
            text: ' y nuestra ',
          ),
          TextSpan(
            text: 'Política de privacidad',
            recognizer: privacyRecognizer,
            style: TextStyle(
              color: palette.primary,
              decoration: TextDecoration.underline,
              decorationColor: palette.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}