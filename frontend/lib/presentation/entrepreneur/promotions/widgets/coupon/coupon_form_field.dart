import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class CouponFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  const CouponFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      cursorColor: palette.primary,
      style: TextStyle(
        color: palette.text,
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: palette.mutedText,
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w600,
        ),
        errorStyle: TextStyle(
          color: RoleTheme.iconDanger,
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(
          icon,
          color: RoleTheme.iconColorFor(
            icon,
            fallback: palette.primary,
          ),
          size: 20.sp,
        ),
        filled: true,
        fillColor: palette.primary.withValues(alpha: 0.035),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 12.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: palette.primary.withValues(alpha: 0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: palette.primary,
            width: 1.2.w,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: RoleTheme.iconDanger.withValues(alpha: 0.75),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: RoleTheme.iconDanger,
            width: 1.2.w,
          ),
        ),
      ),
    );
  }
}