import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class PromotionFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final int? maxLength;
  final String? suffixText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const PromotionFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.maxLength,
    this.suffixText,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final hint = label.trim().isNotEmpty ? label.trim() : 'Ingrese un valor';
    final suffix = suffixText?.trim();

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: validator,
      cursorColor: palette.primary,
      style: TextStyle(
        color: palette.text,
        fontSize: 12.2.sp,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: hint,
        suffixText: suffix?.isNotEmpty == true ? suffix : null,
        suffixStyle: TextStyle(
          color: palette.primary,
          fontSize: 11.sp,
          fontWeight: FontWeight.w900,
        ),
        counterStyle: TextStyle(
          color: palette.mutedText.withValues(alpha: 0.68),
          fontSize: 9.2.sp,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: TextStyle(
          color: palette.mutedText.withValues(alpha: 0.82),
          fontSize: 10.8.sp,
          fontWeight: FontWeight.w600,
        ),
        errorStyle: TextStyle(
          color: RoleTheme.iconDanger,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(
          icon,
          color: RoleTheme.iconColorFor(
            icon,
            fallback: palette.primary,
          ),
          size: 17.sp,
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 40.w),
        filled: true,
        fillColor: palette.surface,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 11.w,
          vertical: 10.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11.r),
          borderSide: BorderSide(
            color: palette.primary.withValues(alpha: 0.14),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11.r),
          borderSide: BorderSide(
            color: palette.primary,
            width: 1.15.w,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11.r),
          borderSide: BorderSide(
            color: RoleTheme.iconDanger.withValues(alpha: 0.75),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11.r),
          borderSide: BorderSide(
            color: RoleTheme.iconDanger,
            width: 1.15.w,
          ),
        ),
      ),
    );
  }
}