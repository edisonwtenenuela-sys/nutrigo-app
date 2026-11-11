import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class AppointmentInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;

  const AppointmentInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.trim().isNotEmpty;
    const palette = RoleTheme.client;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 11.h),
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: RoleTheme.iconCalendar.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: RoleTheme.iconCalendar.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(
              icon,
              color: RoleTheme.iconColorFor(
                icon,
                fallback: RoleTheme.iconCalendar,
              ),
              size: 19.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  hasValue ? value!.trim() : 'No especificado',
                  style: TextStyle(
                    color: hasValue
                        ? palette.mutedText
                        : RoleTheme.iconWarning,
                    fontSize: 12.2.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}