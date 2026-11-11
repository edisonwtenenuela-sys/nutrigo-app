import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistPatientsLoadingState extends StatelessWidget {
  final RolePalette palette;

  const NutritionistPatientsLoadingState({
    super.key,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 210.w,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: palette.primary.withValues(alpha: 0.10),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: palette.primary,
            ),
            SizedBox(height: 14.h),
            Text(
              'Cargando pacientes...',
              style: TextStyle(
                color: palette.text,
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}