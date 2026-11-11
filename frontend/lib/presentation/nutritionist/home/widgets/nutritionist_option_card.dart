import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistOptionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const NutritionistOptionCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Card(
      elevation: 1.5,
      color: palette.surface,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: BorderSide(
          color: palette.primary.withValues(alpha: 0.10),
        ),
      ),
      shadowColor: palette.shadow,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 8.h,
        ),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            icon,
            color: RoleTheme.iconColorFor(
              icon,
              fallback: color,
            ),
            size: 22.sp,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: palette.text,
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: palette.mutedText,
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: palette.mutedText,
          size: 16.sp,
        ),
        onTap: onTap,
      ),
    );
  }
}