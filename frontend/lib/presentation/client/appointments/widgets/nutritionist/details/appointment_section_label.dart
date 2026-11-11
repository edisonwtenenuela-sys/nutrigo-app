import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class AppointmentSectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const AppointmentSectionLabel({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Row(
      children: [
        Icon(
          icon,
          color: RoleTheme.iconColorFor(
            icon,
            fallback: RoleTheme.iconInfo,
          ),
          size: 16.sp,
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            color: palette.text,
            fontSize: 13.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}