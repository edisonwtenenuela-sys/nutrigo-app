import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class ProfileStateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  const ProfileStateMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(22.w),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76.w,
                height: 76.w,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 38.sp, color: palette.primary),
              ),
              SizedBox(height: 14.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: palette.mutedText,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 18.h),
              SizedBox(
                width: double.infinity,
                height: 43.h,
                child: OutlinedButton(
                  onPressed: onPressed,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: palette.primary,
                    backgroundColor: palette.primary.withValues(alpha: 0.055),
                    side: BorderSide(
                      color: palette.primary.withValues(alpha: 0.18),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}








