import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class ClientActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final String? loadingLabel;
  final Color? color;
  final double? height;
  final double? fontSize;
  final double? radius;
  final EdgeInsetsGeometry? padding;

  const ClientActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.loadingLabel,
    this.color,
    this.height,
    this.fontSize,
    this.radius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final effectiveColor = color ?? palette.primary;
    final effectiveHeight = height ?? 44.h;
    final effectiveRadius = radius ?? 15.r;
    final effectiveFontSize = fontSize ?? 12.5.sp;

    final buttonStyle = OutlinedButton.styleFrom(
      foregroundColor: effectiveColor,
      backgroundColor: effectiveColor.withValues(alpha: 0.05),
      disabledForegroundColor: effectiveColor.withValues(alpha: 0.45),
      disabledBackgroundColor: effectiveColor.withValues(alpha: 0.04),
      padding: padding ?? EdgeInsets.symmetric(horizontal: 12.w),
      side: BorderSide(color: effectiveColor.withValues(alpha: 0.20)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(effectiveRadius),
      ),
    );

    final labelText = Text(
      isLoading ? (loadingLabel ?? 'Procesando...') : label,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: effectiveFontSize,
      ),
    );

    final leading = isLoading
        ? SizedBox(
            width: 16.w,
            height: 16.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: effectiveColor,
            ),
          )
        : icon == null
        ? null
        : Icon(icon, size: 16.sp);

    return SizedBox(
      width: double.infinity,
      height: effectiveHeight,
      child: leading == null
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: labelText,
            )
          : OutlinedButton.icon(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              icon: leading,
              label: labelText,
            ),
    );
  }
}








