import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class StatusHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const StatusHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    final semanticIconColor = RoleTheme.iconColorFor(
      icon,
      fallback: color,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            semanticIconColor.withValues(alpha: 0.12),
            semanticIconColor.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: semanticIconColor.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: semanticIconColor,
            child: Icon(
              icon,
              color: Colors.white,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 15.2.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 10.8.sp,
                    height: 1.08,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: semanticIconColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(
              Icons.shopping_bag_rounded,
              color: RoleTheme.iconColorFor(
                Icons.shopping_bag_rounded,
                fallback: semanticIconColor,
              ),
              size: 18.sp,
            ),
          ),
        ],
      ),
    );
  }
}