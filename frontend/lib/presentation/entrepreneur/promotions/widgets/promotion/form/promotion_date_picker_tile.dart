import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class PromotionDatePickerTile extends StatelessWidget {
  final String title;
  final String dateText;
  final VoidCallback? onTap;

  const PromotionDatePickerTile({
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
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: palette.primary.withValues(alpha: enabled ? 0.03 : 0.018),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: palette.primary.withValues(alpha: enabled ? 0.10 : 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: palette.primary.withValues(
                  alpha: enabled ? 0.085 : 0.05,
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                color: enabled
                    ? RoleTheme.iconColorFor(
                        Icons.calendar_month_rounded,
                        fallback: palette.primary,
                      )
                    : palette.mutedText,
                size: 17.sp,
              ),
            ),
            SizedBox(width: 9.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: enabled ? palette.text : palette.mutedText,
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    dateText.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.mutedText,
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: enabled ? palette.primary : palette.mutedText,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
