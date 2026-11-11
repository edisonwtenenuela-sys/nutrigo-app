import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class OrderInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const OrderInfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final semanticIconColor = RoleTheme.iconColorFor(
      icon,
      fallback: color,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: semanticIconColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: semanticIconColor,
            size: 13.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: semanticIconColor,
              fontSize: 10.2.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}