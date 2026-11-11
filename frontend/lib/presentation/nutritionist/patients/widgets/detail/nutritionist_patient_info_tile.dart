import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistPatientInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const NutritionistPatientInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  Widget _buildLeadingIcon() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Icon(
        icon,
        color: RoleTheme.iconColorFor(icon, fallback: color),
        size: 21.sp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 11.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(21.r),
        border: Border.all(color: color.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLeadingIcon(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w900,
                    color: palette.text,
                  ),
                ),
                SizedBox(height: 5.h),
                SelectableText(
                  value,
                  style: TextStyle(
                    fontSize: 12.2.sp,
                    color: palette.mutedText,
                    fontWeight: FontWeight.w600,
                    height: 1.32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}