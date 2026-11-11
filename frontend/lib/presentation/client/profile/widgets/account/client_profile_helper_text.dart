import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ClientProfileHelperText extends StatelessWidget {
  final String text;

  const ClientProfileHelperText(
      this.text, {
        super.key,
      });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Padding(
      padding: EdgeInsets.only(
        left: 4.w,
        right: 4.w,
        top: 6.h,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: palette.mutedText,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
    );
  }
}