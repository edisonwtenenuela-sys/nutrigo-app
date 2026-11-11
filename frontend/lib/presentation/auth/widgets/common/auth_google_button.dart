import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class AuthGoogleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final RolePalette? palette;
  final double? height;

  const AuthGoogleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.palette,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePalette = palette ?? RoleTheme.client;
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    final buttonHeight = height ?? (isTablet ? 48.0 : 50.h);
    final iconSize = isTablet ? 20.0 : 21.w;
    final fontSize = isTablet ? 14.0 : 13.5.sp;

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: effectivePalette.text,
          backgroundColor: Color.lerp(
            effectivePalette.surface,
            effectivePalette.background,
            0.22,
          ),
          side: BorderSide(
            color: effectivePalette.primary.withValues(alpha: 0.12),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          textStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/google_logo.png',
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 10.w),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}