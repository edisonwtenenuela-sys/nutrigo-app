import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ClientProfileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const ClientProfileSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(19.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 16.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 31.w,
                height: 31.w,
                decoration: BoxDecoration(
                  color: palette.softPrimary(0.10),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  size: 17.sp,
                  color: RoleTheme.iconColorFor(
                    icon,
                    fallback: palette.primary,
                  ),
                ),
              ),
              SizedBox(width: 9.w),
              Text(
                title,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: 13.h),
          ...children,
        ],
      ),
    );
  }
}