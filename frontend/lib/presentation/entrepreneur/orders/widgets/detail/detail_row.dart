import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;
  final int maxLines;
  final IconData? icon;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
    this.maxLines = 1,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;
    final textColor = valueColor ?? palette.text;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              width: 26.w,
              height: 26.w,
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                size: 14.sp,
                color: RoleTheme.iconColorFor(
                  icon!,
                  fallback: palette.primary,
                ),
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: palette.mutedText,
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 5,
            child: Text(
              value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: textColor,
                fontSize: 12.sp,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}