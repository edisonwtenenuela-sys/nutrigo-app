import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistPatientsEmptyState extends StatelessWidget {
  const NutritionistPatientsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Center(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(
            color: palette.primary.withValues(alpha: 0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 20.r,
              offset: Offset(0, 9.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92.w,
              height: 92.w,
              decoration: BoxDecoration(
                gradient: palette.headerGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: palette.primary.withValues(alpha: 0.18),
                    blurRadius: 18.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.groups_2_rounded,
                size: 44.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'Aún no tienes pacientes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: palette.text,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Los pacientes aparecerán aquí cuando tengas citas confirmadas o completadas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5.sp,
                color: palette.mutedText,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 18.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(13.w),
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: 0.065),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: palette.primary.withValues(alpha: 0.09),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13.r),
                    ),
                    child: Icon(
                      Icons.tips_and_updates_rounded,
                      color: RoleTheme.iconColorFor(
                        Icons.tips_and_updates_rounded,
                        fallback: palette.primary,
                      ),
                      size: 19.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Puedes actualizar deslizando hacia abajo para revisar nuevas citas.',
                      style: TextStyle(
                        fontSize: 11.3.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: palette.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}