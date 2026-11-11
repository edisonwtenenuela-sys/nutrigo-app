import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistPatientSearchBox extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;

  const NutritionistPatientSearchBox({
    super.key,
    required this.controller,
    required this.query,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      cursorColor: palette.primary,
      style: TextStyle(
        color: palette.text,
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: 'Buscar paciente o identificador',
        hintStyle: TextStyle(
          color: palette.mutedText,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: palette.primary,
          size: 21.sp,
        ),
        suffixIcon: query.trim().isEmpty
            ? null
            : IconButton(
          onPressed: () {
            controller.clear();
            onChanged('');
          },
          icon: Icon(
            Icons.close_rounded,
            color: RoleTheme.iconColorFor(
              Icons.close_rounded,
              fallback: palette.mutedText,
            ),
            size: 19.sp,
          ),
        ),
        filled: true,
        fillColor: palette.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: BorderSide(
            color: palette.primary.withValues(alpha: 0.10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: BorderSide(
            color: palette.primary,
            width: 1.3.w,
          ),
        ),
      ),
    );
  }
}