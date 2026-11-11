import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistAppointmentInfoBox extends StatelessWidget {
  final IconData icon;
  final String text;

  const NutritionistAppointmentInfoBox({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: RoleTheme.iconColorFor(
              icon,
              fallback: palette.primary,
            ),
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: palette.mutedText,
                fontSize: 11.sp,
                height: 1.22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}