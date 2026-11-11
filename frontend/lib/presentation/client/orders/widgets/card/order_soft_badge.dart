import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class OrderSoftBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const OrderSoftBadge({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final semanticIconColor = RoleTheme.iconColorFor(
      icon,
      fallback: color,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: semanticIconColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: semanticIconColor,
            size: 8.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color: semanticIconColor,
              fontSize: 9.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}