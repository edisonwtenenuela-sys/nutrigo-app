import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class LoginPrimaryCard extends StatelessWidget {
  final RolePalette palette;
  final bool isTablet;
  final Widget child;

  const LoginPrimaryCard({
    super.key,
    required this.palette,
    required this.isTablet,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isTablet ? 22.0 : 18.w,
        isTablet ? 22.0 : 20.h,
        isTablet ? 22.0 : 18.w,
        isTablet ? 20.0 : 20.h,
      ),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(isTablet ? 28.0 : 28.r),
        border: Border.all(color: palette.surface.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.16),
            blurRadius: isTablet ? 30.0 : 30.r,
            offset: Offset(0, isTablet ? 16.0 : 16.h),
          ),
          BoxShadow(
            color: palette.surface.withValues(alpha: 0.68),
            blurRadius: isTablet ? 12.0 : 12.r,
            offset: Offset(0, isTablet ? -2.0 : -2.h),
          ),
        ],
      ),
      child: child,
    );
  }
}
