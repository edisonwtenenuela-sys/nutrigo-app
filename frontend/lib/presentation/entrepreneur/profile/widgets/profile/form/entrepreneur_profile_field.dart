import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class BusinessProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool enabled;

  const BusinessProfileField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        cursorColor: palette.primary,
        style: TextStyle(
          fontSize: 13.2.sp,
          fontWeight: FontWeight.w700,
          color: enabled ? palette.text : palette.mutedText,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          alignLabelWithHint: maxLines > 1,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w800,
            color: palette.primary,
          ),
          hintStyle: TextStyle(fontSize: 12.sp, color: palette.mutedText),
          prefixIcon: Icon(icon, size: 20.sp, color: palette.primary),
          prefixIconConstraints: BoxConstraints(minWidth: 42.w),
          filled: true,
          fillColor: enabled
              ? palette.primary.withValues(alpha: 0.035)
              : palette.primary.withValues(alpha: 0.025),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: maxLines > 1 ? 12.h : 11.h,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r)),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(
              color: palette.primary.withValues(alpha: 0.10),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(
              color: palette.primary.withValues(alpha: 0.12),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(color: palette.primary, width: 1.3.w),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1.3.w),
          ),
        ),
      ),
    );
  }
}








