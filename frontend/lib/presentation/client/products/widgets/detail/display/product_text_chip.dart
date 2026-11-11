import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ProductTextChip extends StatelessWidget {
  final String label;
  final IconData? icon;

  const ProductTextChip({super.key, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 11.sp,
              color: RoleTheme.iconColorFor(icon!, fallback: palette.primary),
            ),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: TextStyle(
              color: palette.primary,
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
