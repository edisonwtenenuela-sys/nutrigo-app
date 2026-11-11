import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistAppointmentsEmptyState extends StatelessWidget {
  const NutritionistAppointmentsEmptyState({super.key});

  static const _title = 'Aún no tienes citas';
  static const _description =
      'Cuando un cliente agende una consulta contigo, aparecerá aquí para que puedas gestionarla.';
  static const _note =
      'Recuerda mantener tu perfil actualizado para generar confianza.';

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 26.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 28.h),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: palette.primary.withValues(alpha: 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 14.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76.w,
                height: 76.w,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  size: 40.sp,
                  color: RoleTheme.iconCalendar,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                _title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: palette.text,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  color: palette.mutedText,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.055),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: palette.primary.withValues(alpha: 0.10),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: RoleTheme.iconColorFor(
                        Icons.info_outline_rounded,
                        fallback: palette.primary,
                      ),
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
      ),
    );
  }
}