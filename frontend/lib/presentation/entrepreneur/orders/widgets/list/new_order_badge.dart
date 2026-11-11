import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NewOrderBadge extends StatelessWidget {
  const NewOrderBadge({super.key});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 7.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_active_rounded,
            size: 12.sp,
            color: RoleTheme.iconColorFor(
              Icons.notifications_active_rounded,
              fallback: palette.primary,
            ),
          ),
          SizedBox(width: 3.w),
          Text(
            'Nuevo',
            style: TextStyle(
              color: palette.primary,
              fontSize: 9.8.sp,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}