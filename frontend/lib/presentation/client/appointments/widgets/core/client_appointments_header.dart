import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ClientAppointmentsHeader extends StatelessWidget {
  final int total;
  final int pending;
  final int completed;

  const ClientAppointmentsHeader({
    super.key,
    required this.total,
    required this.pending,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.fromLTRB(15.w, 15.h, 15.w, 14.h),
      decoration: BoxDecoration(
        color: RoleTheme.brandBadgeBackground,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: RoleTheme.iconCalendar.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: RoleTheme.iconCalendar.withValues(alpha: 0.07),
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
              color: palette.surface,
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: RoleTheme.iconColorFor(
                Icons.calendar_month_rounded,
                fallback: RoleTheme.iconCalendar,
              ),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$total citas registradas',
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$pending pendientes, $completed completadas',
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 11.2.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            children: [
              _HeaderMetric(
                value: '$pending',
                label: 'Pend.',
                color: RoleTheme.iconWarning,
              ),
              SizedBox(height: 6.h),
              _HeaderMetric(
                value: '$completed',
                label: 'Listas',
                color: RoleTheme.iconValidation,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _HeaderMetric({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Container(
      width: 54.w,
      padding: EdgeInsets.symmetric(vertical: 5.h),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 9.sp,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}