import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class AdminSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AdminSectionTitle({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  Widget _buildLeadingIcon(RolePalette palette) {
    return Container(
      width: 34.w,
      height: 34.w,
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        icon,
        size: 18.sp,
        color: RoleTheme.iconColorFor(
          icon,
          fallback: palette.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.admin;

    return Row(
      children: [
        _buildLeadingIcon(palette),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.mutedText,
                  fontSize: 11.2.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}