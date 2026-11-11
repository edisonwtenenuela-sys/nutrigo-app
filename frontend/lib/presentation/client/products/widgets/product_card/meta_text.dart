import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MetaText extends StatelessWidget {
  final IconData icon;
  final String label;

  const MetaText({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: RoleTheme.iconColorFor(icon, fallback: palette.mutedText),
          size: 11.sp,
        ),
        SizedBox(width: 3.w),
        Text(
          label,
          style: TextStyle(
            color: palette.mutedText,
            fontSize: 9.2.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
