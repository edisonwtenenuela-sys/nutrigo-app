import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class DetailSectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;

  const DetailSectionTitle({
    super.key,
    required this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Padding(
      padding: EdgeInsets.only(top: 6.h, bottom: 8.h),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                size: 17.sp,
                color: RoleTheme.iconColorFor(
                  icon!,
                  fallback: palette.primary,
                ),
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.primary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}