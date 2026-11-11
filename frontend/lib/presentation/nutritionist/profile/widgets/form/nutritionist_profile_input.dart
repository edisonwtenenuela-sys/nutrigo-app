import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistProfileInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final VoidCallback? onChanged;
  final bool enabled;

  const NutritionistProfileInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hintText,
    this.maxLines = 1,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  Widget _buildPrefixIcon(RolePalette palette) {
    return Padding(
      padding: EdgeInsets.only(left: 10.w, right: 8.w),
      child: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: palette.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(RolePalette palette) {
    final radius = BorderRadius.circular(18.r);

    return InputDecoration(
      hintText: hintText,
      alignLabelWithHint: maxLines > 1,
      hintStyle: TextStyle(
        fontSize: 12.sp,
        color: palette.mutedText.withValues(alpha: 0.72),
        fontWeight: FontWeight.w500,
        height: 1.25,
      ),
      prefixIcon: _buildPrefixIcon(palette),
      prefixIconConstraints: BoxConstraints(minWidth: 58.w),
      filled: true,
      fillColor: enabled
          ? palette.background
          : palette.background.withValues(alpha: 0.55),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: maxLines > 1 ? 14.h : 12.h,
      ),
      border: OutlineInputBorder(borderRadius: radius),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: palette.primary.withValues(alpha: 0.10)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: palette.primary.withValues(alpha: 0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: palette.primary, width: 1.3.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: RoleTheme.iconDanger.withValues(alpha: 0.55),
          width: 1.2.w,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: RoleTheme.iconDanger.withValues(alpha: 0.75),
          width: 1.3.w,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 2.w, bottom: 6.h),
          child: Text(
            label,
            style: TextStyle(
              color: enabled ? palette.text : palette.mutedText,
              fontSize: 11.3.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: (_) => onChanged?.call(),
          cursorColor: palette.primary,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: palette.text,
            height: 1.35,
          ),
          decoration: _inputDecoration(palette),
        ),
      ],
    );
  }
}