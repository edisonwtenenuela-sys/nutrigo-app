import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool readOnly;

  const ProfileField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      readOnly: readOnly,
      style: TextStyle(
        color: palette.text,
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        labelStyle: TextStyle(
          color: palette.mutedText,
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          icon,
          size: 18.sp,
          color: RoleTheme.iconColorFor(
            icon,
            fallback: palette.primary,
          ),
        ),
        filled: true,
        fillColor: readOnly
            ? palette.background.withValues(alpha: 0.72)
            : Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 12.h,
        ),
        border: _border(
          palette.primary.withValues(alpha: 0.12),
        ),
        enabledBorder: _border(
          palette.primary.withValues(alpha: 0.12),
        ),
        focusedBorder: _border(
          palette.primary,
          width: 1.2,
        ),
        errorBorder: _border(
          Colors.red,
        ),
        focusedErrorBorder: _border(
          Colors.red,
          width: 1.2,
        ),
      ),
    );
  }

  OutlineInputBorder _border(
      Color color, {
        double width = 1,
      }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.r),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}