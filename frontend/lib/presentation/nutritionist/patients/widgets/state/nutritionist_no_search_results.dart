import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistNoSearchResults extends StatelessWidget {
  final String query;

  const NutritionistNoSearchResults({
    super.key,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_search_rounded,
            color: RoleTheme.iconColorFor(
              Icons.person_search_rounded,
              fallback: palette.primary,
            ),
            size: 42.sp,
          ),
          SizedBox(height: 10.h),
          Text(
            'No se encontraron pacientes',
            style: TextStyle(
              color: palette.text,
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'No hay resultados para "$query".',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}