import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class BusinessProfileQuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const BusinessProfileQuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  bool get _isLogout => title.toLowerCase().contains('cerrar');

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;
    final color = _isLogout ? Colors.red : palette.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: Ink(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: _isLogout
                  ? Colors.red.withValues(alpha: 0.035)
                  : palette.surface,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: color.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.018),
                  blurRadius: 13.r,
                  offset: Offset(0, 7.h),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(icon, color: color, size: 22.sp),
                ),
                SizedBox(width: 13.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.7.sp,
                          fontWeight: FontWeight.w900,
                          color: _isLogout ? Colors.red.shade700 : palette.text,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.8.sp,
                          height: 1.25,
                          color: palette.mutedText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13.sp,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}








