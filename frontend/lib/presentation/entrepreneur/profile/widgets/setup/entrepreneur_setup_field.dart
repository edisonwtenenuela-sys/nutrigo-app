import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class BusinessSetupField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  const BusinessSetupField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.enabled,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Padding(
      padding: EdgeInsets.only(bottom: 9.h),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        style: TextStyle(
          color: palette.text,
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: palette.mutedText,
            fontSize: 11.8.sp,
            fontWeight: FontWeight.w700,
          ),
          prefixIcon: Icon(
            icon,
            color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
            size: 18.sp,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 42.w,
            minHeight: 42.h,
          ),
          filled: true,
          fillColor: const Color(0xFFF6F8FC),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 13.w,
            vertical: maxLines > 1 ? 13.h : 12.h,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(
              color: palette.primary.withValues(alpha: 0.14),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(
              color: palette.primary.withValues(alpha: 0.55),
              width: 1.3,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: Colors.red.withValues(alpha: 0.55)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(
              color: Colors.red.withValues(alpha: 0.75),
              width: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}








