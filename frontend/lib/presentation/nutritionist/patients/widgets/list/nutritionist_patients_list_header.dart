import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NutritionistPatientsListHeader extends StatelessWidget {
  final RolePalette palette;
  final String query;
  final int count;

  const NutritionistPatientsListHeader({
    super.key,
    required this.palette,
    required this.query,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          query.trim().isEmpty
              ? 'Pacientes recientes'
              : 'Resultados encontrados',
          style: TextStyle(
            color: palette.text,
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        Text(
          '$count',
          style: TextStyle(
            color: palette.primary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}