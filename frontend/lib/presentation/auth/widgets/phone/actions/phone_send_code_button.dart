import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class PhoneSendCodeButton extends StatelessWidget {
  final RolePalette palette;
  final bool isLoading;
  final bool otpSent;
  final VoidCallback onPressed;

  const PhoneSendCodeButton({
    super.key,
    required this.palette,
    required this.isLoading,
    required this.otpSent,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 51.h,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: palette.primary.withValues(alpha: 0.35),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.72),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        icon: isLoading && !otpSent
            ? SizedBox(
          width: 20.w,
          height: 20.w,
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.2,
          ),
        )
            : Icon(
          Icons.send_rounded,
          size: 18.sp,
          color: RoleTheme.iconColorFor(
            Icons.send_rounded,
            fallback: Colors.white,
          ),
        ),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            otpSent
                ? 'Enviar código nuevamente'
                : 'Enviar código SMS',
            maxLines: 1,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}