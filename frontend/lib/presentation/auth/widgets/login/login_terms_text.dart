import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class LoginTermsText extends StatelessWidget {
  final TapGestureRecognizer termsRecognizer;
  final TapGestureRecognizer privacyRecognizer;

  const LoginTermsText({
    super.key,
    required this.termsRecognizer,
    required this.privacyRecognizer,
  });

  bool _isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 600;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    const palette = RoleTheme.client;

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          color: palette.mutedText,
          fontSize: isTablet ? 11.0 : 11.sp,
          fontWeight: FontWeight.w600,
        ),
        children: [
          const TextSpan(
            text: 'Aceptas ',
          ),
          TextSpan(
            text: 'Términos',
            recognizer: termsRecognizer,
            style: TextStyle(
              color: palette.primary,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w700,
            ),
          ),
          const TextSpan(
            text: ' y ',
          ),
          TextSpan(
            text: 'Privacidad',
            recognizer: privacyRecognizer,
            style: TextStyle(
              color: palette.primary,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}