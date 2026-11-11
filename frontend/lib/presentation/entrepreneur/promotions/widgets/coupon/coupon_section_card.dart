import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class CouponSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;

  const CouponSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final hasSubtitle = subtitle?.trim().isNotEmpty ?? false;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.04),
            blurRadius: 16.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(13.r),
                ),
                child: Icon(
                  icon,
                  color: RoleTheme.iconColorFor(
                    icon,
                    fallback: palette.primary,
                  ),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (hasSubtitle) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle!.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.mutedText,
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 13.h),
          child,
        ],
      ),
    );
  }
}