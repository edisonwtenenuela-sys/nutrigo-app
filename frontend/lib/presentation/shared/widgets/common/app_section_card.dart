import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class AppSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackground;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const AppSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.iconColor,
    this.iconBackground,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final resolvedIconColor =
        iconColor ??
            RoleTheme.iconColorFor(
              icon,
              fallback: colorScheme.primary,
            );

    final resolvedIconBackground =
        iconBackground ?? RoleTheme.brandBadgeBackground;

    return Container(
      padding: padding ?? EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: RoleTheme.brandBorder.withValues(alpha: 0.78),
        ),
        boxShadow: [
          BoxShadow(
            color: RoleTheme.brandPrimary.withValues(alpha: 0.025),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26.w,
                height: 26.w,
                decoration: BoxDecoration(
                  color: resolvedIconBackground,
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(
                  icon,
                  color: resolvedIconColor,
                  size: 15.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 13.6.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }
}