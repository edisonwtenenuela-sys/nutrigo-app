import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistQuickInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? color;

  const NutritionistQuickInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;
    final iconColor = color ?? RoleTheme.iconColorFor(icon, fallback: palette.primary);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: iconColor.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 22.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: palette.mutedText,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              color: palette.text,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}