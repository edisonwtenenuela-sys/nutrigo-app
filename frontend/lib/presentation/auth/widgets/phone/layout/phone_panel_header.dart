import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class PhonePanelHeader extends StatelessWidget {
  final bool otpSent;
  final RolePalette palette;

  const PhonePanelHeader({
    super.key,
    required this.otpSent,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final isCodeStep = otpSent;
    final icon = otpSent ? Icons.sms_rounded : Icons.phone_android_rounded;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: isCodeStep ? 38.w : 42.w,
          height: isCodeStep ? 38.w : 42.w,
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Icon(
            icon,
            color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
            size: 22.sp,
          ),
        ),
        SizedBox(width: 11.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                otpSent ? 'Confirma el código' : 'Número de acceso',
                style: TextStyle(
                  color: palette.text,
                  fontSize: isCodeStep ? 14.sp : 15.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: isCodeStep ? 2.h : 3.h),
              Text(
                otpSent
                    ? 'Ingresa el código enviado por SMS.'
                    : 'Ingresa tu número celular de Ecuador.',
                style: TextStyle(
                  color: palette.mutedText,
                  fontSize: isCodeStep ? 10.8.sp : 11.2.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            otpSent ? 'Paso 2' : 'Paso 1',
            style: TextStyle(
              color: palette.primary,
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}