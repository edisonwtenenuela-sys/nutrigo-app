import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class CouponDatePickerTile extends StatelessWidget {
  final String title;
  final String dateText;
  final VoidCallback? onTap;

  const CouponDatePickerTile({
    super.key,
    required this.title,
    required this.dateText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: palette.primary.withValues(alpha: enabled ? 0.035 : 0.018),
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: palette.primary.withValues(alpha: enabled ? 0.10 : 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: enabled ? 0.09 : 0.05),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                color: enabled
                    ? RoleTheme.iconColorFor(
                  Icons.calendar_month_rounded,
                  fallback: palette.primary,
                )
                    : palette.mutedText,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: enabled ? palette.text : palette.mutedText,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    dateText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.mutedText,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
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
                color: palette.surface,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: palette.primary.withValues(alpha: 0.08),
                ),
              ),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: enabled ? palette.primary : palette.mutedText,
                size: 22.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}