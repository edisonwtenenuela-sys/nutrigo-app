import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class BusinessProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? content;

  const BusinessProfileInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;
    final hasContent = content != null && content!.trim().isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: hasContent
              ? palette.primary.withValues(alpha: 0.10)
              : palette.primary.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: palette.primary.withValues(
                alpha: hasContent ? 0.08 : 0.12,
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              icon,
              color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
              size: 22.sp,
            ),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF263238),
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  hasContent ? content!.trim() : 'No especificado',
                  style: TextStyle(
                    fontSize: 12.8.sp,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: hasContent ? Colors.grey.shade800 : palette.primary,
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








