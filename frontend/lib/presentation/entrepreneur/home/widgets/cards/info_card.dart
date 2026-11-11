import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String caption;
  final IconData icon;
  final Color? valueColor;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    const palette = RoleTheme.entrepreneur;
    final color = valueColor ?? palette.primary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 13 : 10.w,
        vertical: isTablet ? 12 : 9.h,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 14.r),
        border: Border.all(color: color.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.04),
            blurRadius: isTablet ? 12 : 9.r,
            offset: Offset(0, isTablet ? 5 : 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: isTablet ? 34 : 31.w,
            height: isTablet ? 34 : 31.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(
              icon,
              color: RoleTheme.iconColorFor(icon, fallback: color),
              size: isTablet ? 16 : 14.sp,
            ),
          ),
          SizedBox(height: isTablet ? 10 : 8.h),
          Text(
            value,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: isTablet ? 20 : 17.sp,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            title,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.text,
              fontSize: isTablet ? 12 : 10.8.sp,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            caption,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.mutedText,
              fontSize: isTablet ? 10 : 8.8.sp,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
