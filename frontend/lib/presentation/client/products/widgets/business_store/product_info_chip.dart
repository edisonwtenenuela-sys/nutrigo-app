import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double? maxWidth;

  const ProductInfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: maxWidth == null
          ? null
          : BoxConstraints(maxWidth: maxWidth!),
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: RoleTheme.brandChipBackground,
        borderRadius: BorderRadius.circular(99.r),
        border: Border.all(color: RoleTheme.brandBorder),
      ),
      child: Row(
        mainAxisSize: maxWidth == null ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Icon(icon, color: color, size: 11.sp),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 9.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
