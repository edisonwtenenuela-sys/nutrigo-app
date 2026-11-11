import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistProductsEmptyState extends StatelessWidget {
  const NutritionistProductsEmptyState({
    super.key,
    this.title = 'Todo está al día',
    this.description =
    'No tienes productos en este estado. Cuando existan, aparecerán aquí.',
  });

  final String title;
  final String description;

  static const _note =
      'Tu validación ayuda a mantener productos saludables y confiables dentro de la plataforma.';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 28.h),
          decoration: BoxDecoration(
            color: RoleTheme.brandSurface,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: RoleTheme.brandBorder.withValues(alpha: 0.72),
            ),
            boxShadow: [
              BoxShadow(
                color: RoleTheme.brandPrimary.withValues(alpha: 0.06),
                blurRadius: 14.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78.w,
                height: 78.w,
                decoration: BoxDecoration(
                  color: RoleTheme.iconValidation.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_rounded,
                  size: 42.sp,
                  color: RoleTheme.iconValidation,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w900,
                  color: RoleTheme.brandText,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: RoleTheme.brandMutedText,
                  fontSize: 12.5.sp,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: RoleTheme.brandBadgeBackground,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.health_and_safety_rounded,
                      color: RoleTheme.iconHealth,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _note,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: RoleTheme.brandText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}