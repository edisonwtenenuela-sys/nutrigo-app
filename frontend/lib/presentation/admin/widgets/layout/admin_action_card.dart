import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class AdminActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const AdminActionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  Widget _buildTrailing(RolePalette palette) {
    return Container(
      width: 34.w,
      height: 34.w,
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14.sp,
        color: palette.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.admin;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22.r),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: palette.primary.withValues(alpha: 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: palette.primary.withValues(alpha: 0.055),
                blurRadius: 18.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54.w,
                height: 54.w,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 14.w),
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
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.mutedText,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.30,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              _buildTrailing(palette),
            ],
          ),
        ),
      ),
    );
  }
}