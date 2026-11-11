import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class DashboardTipCard extends StatelessWidget {
  final String message;

  const DashboardTipCard({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    const palette = RoleTheme.entrepreneur;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 18 : 15.w,
        vertical: isTablet ? 15 : 13.h,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(isTablet ? 22 : 18.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: isTablet ? 16 : 13.r,
            offset: Offset(0, isTablet ? 8 : 6.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isTablet ? 43 : 39.w,
            height: isTablet ? 43 : 39.w,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.tips_and_updates_rounded,
              color: RoleTheme.iconColorFor(
                Icons.tips_and_updates_rounded,
                fallback: palette.primary,
              ),
              size: isTablet ? 22 : 19.sp,
            ),
          ),
          SizedBox(width: isTablet ? 14 : 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Siguiente mejor acción',
                  style: TextStyle(
                    color: palette.text,
                    fontSize: isTablet ? 13.5 : 12.5.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  message,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: isTablet ? 12.2 : 11.sp,
                    height: 1.35,
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