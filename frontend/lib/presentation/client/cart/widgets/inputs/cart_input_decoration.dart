import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

InputDecoration cartInputDecoration({
  required String label,
  required IconData icon,
}) {
  const palette = RoleTheme.client;

  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      fontSize: 13.sp,
      color: palette.mutedText,
      fontWeight: FontWeight.w600,
    ),
    filled: true,
    fillColor: palette.background,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide.none,
    ),
    prefixIcon: Icon(
      icon,
      color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
      size: 20.sp,
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: 14.w,
      vertical: 14.h,
    ),
  );
}