import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class ProductSubmitProgressCard extends StatelessWidget {
  const ProductSubmitProgressCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18.w,
            height: 18.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.1,
              color: palette.primary,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'No cierres esta pantalla mientras se sube la información.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 10.sp,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
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
