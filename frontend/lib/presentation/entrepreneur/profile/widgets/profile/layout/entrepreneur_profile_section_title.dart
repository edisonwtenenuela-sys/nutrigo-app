import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class BusinessProfileSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;

  const BusinessProfileSectionTitle({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(
              icon,
              color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
              size: 21.sp,
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
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w900,
                    color: palette.text,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 3.h),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.3,
                      color: palette.mutedText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}








