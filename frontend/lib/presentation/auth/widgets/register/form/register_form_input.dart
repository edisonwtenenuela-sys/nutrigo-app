import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class RegisterFormInput extends StatelessWidget {
  const RegisterFormInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    required this.palette,
    required this.enabled,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.onChanged,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  final RolePalette palette;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(15.r);

    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      enabled: enabled,
      onChanged: onChanged,
      cursorColor: palette.primary,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: palette.text,
      ),
      decoration: _inputDecoration(radius),
    );
  }

  InputDecoration _inputDecoration(BorderRadius radius) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: palette.mutedText,
      ),
      prefixIcon: Icon(
        icon,
        color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
        size: 20.sp,
      ),
      prefixIconConstraints: BoxConstraints(minWidth: 42.w),
      filled: true,
      fillColor: palette.surface.withValues(alpha: 0.82),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 12.h,
      ),
      border: OutlineInputBorder(borderRadius: radius),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: palette.primary.withValues(alpha: 0.12),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: palette.primary,
          width: 1.4.w,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: RoleTheme.iconDanger,
          width: 1.2.w,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: RoleTheme.iconDanger,
          width: 1.4.w,
        ),
      ),
    );
  }
}