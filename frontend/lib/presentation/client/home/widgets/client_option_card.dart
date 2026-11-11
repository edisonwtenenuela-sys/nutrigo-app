import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class ClientOptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ClientOptionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final semanticIconColor = RoleTheme.iconColorFor(icon, fallback: iconColor);

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Material(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 9.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: semanticIconColor.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 41.w,
                  height: 41.w,
                  decoration: BoxDecoration(
                    color: semanticIconColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Icon(icon, color: semanticIconColor, size: 21.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.text,
                          fontWeight: FontWeight.w900,
                          fontSize: 13.5.sp,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.mutedText,
                          fontSize: 11.3.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.chevron_right_rounded,
                  color: semanticIconColor,
                  size: 22.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}