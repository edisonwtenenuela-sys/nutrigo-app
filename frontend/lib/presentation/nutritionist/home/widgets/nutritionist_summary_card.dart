import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const NutritionistSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  double _resolveValueFontSize() {
    return value.length > 3 ? 15.sp : 17.sp;
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    final iconColor = RoleTheme.iconColorFor(
      icon,
      fallback: color,
    );

    return Container(
      constraints: BoxConstraints(minHeight: 86.h),
      padding: EdgeInsets.symmetric(
        horizontal: 9.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 17.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _resolveValueFontSize(),
              fontWeight: FontWeight.w900,
              color: palette.text,
              height: 1,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: palette.mutedText,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}