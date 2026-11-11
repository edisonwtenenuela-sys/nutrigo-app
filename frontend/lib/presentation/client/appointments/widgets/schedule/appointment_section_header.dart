import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class AppointmentSectionHeader extends StatelessWidget {
  final int totalNutritionists;

  const AppointmentSectionHeader({
    super.key,
    required this.totalNutritionists,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(15.w, 15.h, 15.w, 14.h),
      decoration: BoxDecoration(
        color: RoleTheme.brandBadgeBackground,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: RoleTheme.brandSoft),
        boxShadow: [
          BoxShadow(
            color: RoleTheme.brandPrimary.withValues(alpha: 0.07),
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: RoleTheme.brandSoft),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(
              Icons.health_and_safety_rounded,
              color: RoleTheme.iconHealth,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Elige un nutricionista',
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Agenda una consulta con profesionales verificados.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 11.2.sp,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            width: 58.w,
            padding: EdgeInsets.symmetric(vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: RoleTheme.brandSoft),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Text(
                  '$totalNutritionists',
                  style: TextStyle(
                    color: RoleTheme.iconHealth,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Activos',
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 8.7.sp,
                    fontWeight: FontWeight.w800,
                    height: 1,
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