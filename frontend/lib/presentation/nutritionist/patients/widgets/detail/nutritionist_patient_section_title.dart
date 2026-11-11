import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistPatientSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const NutritionistPatientSectionTitle({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: palette.primary.withValues(alpha: 0.10),
            ),
          ),
          child: Icon(
            icon,
            color: RoleTheme.iconColorFor(
              icon,
              fallback: palette.primary,
            ),
            size: 18.sp,
          ),
        ),
        SizedBox(width: 9.w),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.text,
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}