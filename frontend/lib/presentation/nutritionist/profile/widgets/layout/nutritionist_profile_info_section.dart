import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistProfileInfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const NutritionistProfileInfoSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 12.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 11.h),
          ...children,
        ],
      ),
    );
  }
}

class NutritionistProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final int? maxLines;

  const NutritionistProfileInfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;
    final hasValue = value != null && value!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 9.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
              size: 18.sp,
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 11.2.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  hasValue ? value!.trim() : 'No especificado',
                  maxLines: maxLines,
                  overflow: maxLines != null
                      ? TextOverflow.ellipsis
                      : TextOverflow.visible,
                  style: TextStyle(
                    color: hasValue ? palette.mutedText : RoleTheme.iconWarning,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
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