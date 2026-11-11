import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistVerificationEmptyState extends StatelessWidget {
  const NutritionistVerificationEmptyState({super.key});

  bool _isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 600;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    const palette = RoleTheme.admin;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(
          isTablet ? 28 : 24.w,
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            isTablet ? 28 : 24.w,
          ),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(26.r),
            border: Border.all(
              color: palette.primary.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: palette.primary.withValues(alpha: 0.045),
                blurRadius: 18.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 82.w,
                height: 82.w,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  size: isTablet ? 44 : 40.sp,
                  color: RoleTheme.iconColorFor(
                    Icons.verified_user_rounded,
                    fallback: palette.primary,
                  ),
                ),
              ),
              SizedBox(
                height: isTablet ? 18 : 16.h,
              ),
              Text(
                'No hay nutricionistas pendientes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.text,
                  fontSize: isTablet ? 21 : 19.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(
                height: 8.h,
              ),
              Text(
                'Cuando un nutricionista solicite aprobación, aparecerá en esta sección.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.mutedText,
                  fontSize: isTablet ? 13 : 12.5.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}