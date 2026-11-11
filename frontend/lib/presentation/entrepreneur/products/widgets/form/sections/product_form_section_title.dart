import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class ProductFormSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const ProductFormSectionTitle({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Row(
      children: [
        Container(
          width: 31.w,
          height: 31.w,
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
            size: 17.sp,
          ),
        ),
        SizedBox(width: 9.w),
        Text(
          title,
          style: TextStyle(
            color: palette.text,
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}








