import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ClientProfileErrorCard extends StatelessWidget {
  final String message;

  const ClientProfileErrorCard({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: RoleTheme.iconDanger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: RoleTheme.iconDanger.withValues(alpha: 0.14),
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: RoleTheme.iconDanger,
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w800,
          height: 1.25,
        ),
      ),
    );
  }
}