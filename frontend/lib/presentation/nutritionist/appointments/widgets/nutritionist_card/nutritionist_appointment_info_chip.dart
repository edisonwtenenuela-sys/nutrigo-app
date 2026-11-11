import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistAppointmentInfoChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final Color color;

  const NutritionistAppointmentInfoChip({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });

  Widget _buildTextBlock(RolePalette palette) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.2.sp,
              color: palette.mutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 15.sp,
            color: RoleTheme.iconColorFor(
              icon,
              fallback: color,
            ),
          ),
          SizedBox(width: 6.w),
          _buildTextBlock(palette),
        ],
      ),
    );
  }
}