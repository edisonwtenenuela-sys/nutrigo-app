import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class AppointmentProcessingDialog extends StatelessWidget {
  const AppointmentProcessingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 28.w),
          padding: EdgeInsets.symmetric(
            horizontal: 22.w,
            vertical: 24.h,
          ),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: RoleTheme.iconPayments.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 34.w,
                height: 34.w,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: RoleTheme.iconPayments,
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'Procesando pago...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Si el método de pago no regresa automáticamente, vuelve a la aplicación.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.mutedText,
                  fontSize: 12.sp,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}