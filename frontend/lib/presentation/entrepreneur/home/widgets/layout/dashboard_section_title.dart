import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class DashboardSectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const DashboardSectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Row(
      children: [
        Container(
          width: 31.w,
          height: 31.w,
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.dashboard_customize_rounded,
            color: palette.primary,
            size: 17.sp,
          ),
        ),
        SizedBox(width: 9.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.mutedText,
                  fontSize: 10.8.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}