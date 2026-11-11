import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistAppointmentsErrorState extends StatelessWidget {
  final String message;

  const NutritionistAppointmentsErrorState({
    super.key,
    required this.message,
  });

  static const _title = 'No se pudieron cargar las citas';

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 26.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: RoleTheme.iconDanger.withValues(alpha: 0.14),
            ),
            boxShadow: [
              BoxShadow(
                color: palette.primary.withValues(alpha: 0.05),
                blurRadius: 14.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: RoleTheme.iconDanger.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 38.sp,
                  color: RoleTheme.iconDanger,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                _title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: palette.text,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  color: RoleTheme.iconDanger,
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