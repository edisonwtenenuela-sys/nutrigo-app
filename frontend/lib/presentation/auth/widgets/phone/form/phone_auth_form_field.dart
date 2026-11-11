import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class PhoneAuthFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final RolePalette palette;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  const PhoneAuthFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.palette,
    required this.enabled,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(15.r);

    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
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
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(
          icon,
          color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
          size: 20.sp,
        ),
        filled: true,
        fillColor: palette.primary.withValues(alpha: 0.035),
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: palette.primary.withValues(alpha: 0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: palette.primary, width: 1.4.w),
        ),
      ),
    );
  }
}