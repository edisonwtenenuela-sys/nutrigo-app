import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistProductInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const NutritionistProductInfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  TextStyle _labelStyle() {
    return TextStyle(
      fontSize: 11.sp,
      fontWeight: FontWeight.w800,
      color: color,
      height: 1.1,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15.sp,
            color: RoleTheme.iconColorFor(
              icon,
              fallback: color,
            ),
          ),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: _labelStyle(),
            ),
          ),
        ],
      ),
    );
  }
}