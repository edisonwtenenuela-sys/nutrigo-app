import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class PhoneOtpForm extends StatelessWidget {
  final TextEditingController otpController;
  final bool isLoading;
  final bool otpSent;
  final bool canVerify;
  final VoidCallback onVerifyOtp;
  final RolePalette palette;

  const PhoneOtpForm({
    super.key,
    required this.otpController,
    required this.isLoading,
    required this.otpSent,
    required this.canVerify,
    required this.onVerifyOtp,
    this.palette = RoleTheme.client,
  });

  @override
  Widget build(BuildContext context) {
    if (!otpSent) return const SizedBox.shrink();

    final radius = BorderRadius.circular(16.r);

    return Column(
      children: [
        SizedBox(height: 12.h),
        TextFormField(
          controller: otpController,
          keyboardType: TextInputType.number,
          enabled: !isLoading,
          cursorColor: palette.primary,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: palette.text,
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
          decoration: InputDecoration(
            counterText: '',
            labelText: 'Código de verificación',
            helperText: 'Ingresa los 6 dígitos recibidos por SMS.',
            helperStyle: TextStyle(
              color: palette.mutedText,
              fontSize: 10.4.sp,
              fontWeight: FontWeight.w700,
            ),
            labelStyle: TextStyle(
              color: palette.mutedText,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
            prefixIcon: Icon(
              Icons.sms_rounded,
              color: RoleTheme.iconColorFor(
                Icons.sms_rounded,
                fallback: palette.primary,
              ),
              size: 20.sp,
            ),
            filled: true,
            fillColor: palette.primary.withValues(alpha: 0.035),
            border: OutlineInputBorder(borderRadius: radius),
            enabledBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(
                color: palette.primary.withValues(alpha: 0.12),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: palette.primary, width: 1.4.w),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton.icon(
            onPressed: isLoading || !canVerify ? null : onVerifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: palette.primary,
              foregroundColor: palette.surface,
              disabledBackgroundColor: palette.primary.withValues(alpha: 0.35),
              disabledForegroundColor: palette.surface.withValues(alpha: 0.72),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            icon: isLoading
                ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(
                color: palette.surface,
                strokeWidth: 2,
              ),
            )
                : Icon(
              Icons.verified_user_rounded,
              color: palette.surface,
              size: 18.sp,
            ),
            label: Text(
              isLoading ? 'Verificando...' : 'Verificar y continuar',
              style: TextStyle(
                fontSize: 13.6.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}