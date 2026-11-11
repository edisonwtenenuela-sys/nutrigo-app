import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class AppointmentGuaranteeCard extends StatelessWidget {
  const AppointmentGuaranteeCard({super.key});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: RoleTheme.iconValidation.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: RoleTheme.iconValidation.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: RoleTheme.iconValidation.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.verified_user_outlined,
              size: 18.sp,
              color: RoleTheme.iconColorFor(
                Icons.verified_user_outlined,
                fallback: RoleTheme.iconValidation,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cita protegida',
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 12.2.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Puedes reprogramar sin costo con 24 h de anticipación.',
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 10.5.sp,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
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