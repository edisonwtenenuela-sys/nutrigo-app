import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ClientHealthCard extends StatelessWidget {
  const ClientHealthCard({super.key});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: RoleTheme.iconHealth.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: RoleTheme.iconHealth.withValues(alpha: 0.05),
            blurRadius: 12.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 47.w,
            height: 47.w,
            decoration: BoxDecoration(
              color: RoleTheme.iconHealth.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: RoleTheme.iconHealth,
              size: 25.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alimentación saludable',
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Elige productos aprobados, revisa pedidos y cuida tus hábitos.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.mutedText,
                    height: 1.25,
                    fontSize: 11.7.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}