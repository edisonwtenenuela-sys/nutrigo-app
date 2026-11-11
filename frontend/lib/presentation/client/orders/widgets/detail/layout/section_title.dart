import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Padding(
      padding: EdgeInsets.only(left: 2.w, bottom: 2.h),
      child: Text(
        title,
        style: TextStyle(
          color: palette.mutedText,
          fontSize: 12.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}