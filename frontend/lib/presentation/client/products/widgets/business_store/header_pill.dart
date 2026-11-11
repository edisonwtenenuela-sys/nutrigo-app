import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HeaderPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const HeaderPill({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final iconColor = RoleTheme.iconColorFor(
      icon,
      fallback: RoleTheme.iconInfo,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: RoleTheme.brandSoft.withValues(alpha: 0.72)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 12.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color: iconColor,
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
