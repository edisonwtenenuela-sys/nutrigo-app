import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/entrepreneur/controllers/stats_controller.dart';

class PeakHoursWidget extends StatelessWidget {
  final StatsController statsController;

  const PeakHoursWidget({
    super.key,
    required this.statsController,
  });

  @override
  Widget build(BuildContext context) {
    final peakHours = statsController.peakSalesHours;

    if (peakHours.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedHours = peakHours.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3Hours = sortedHours.take(3).toList();

    const palette = RoleTheme.entrepreneur;

    return Container(
      padding: EdgeInsets.all(9.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18.r),
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
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: RoleTheme.iconColorFor(
                    Icons.local_fire_department_rounded,
                    fallback: palette.primary,
                  ),
                  size: 19.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Horas pico',
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Momentos con mayor movimiento de pedidos.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.mutedText,
                        fontSize: 9.8.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 9.h),
          ...top3Hours.map((entry) {
            final hour = entry.key;
            final salesCount = entry.value;

            return Container(
              margin: EdgeInsets.only(bottom: 7.h),
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: 0.045),
                borderRadius: BorderRadius.circular(13.r),
                border: Border.all(
                  color: palette.primary.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: palette.primary.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Icon(
                      Icons.schedule_rounded,
                      color: RoleTheme.iconColorFor(
                        Icons.schedule_rounded,
                        fallback: palette.primary,
                      ),
                      size: 17.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$hour:00 - ${hour + 1}:00',
                          style: TextStyle(
                            color: palette.text,
                            fontSize: 11.3.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '$salesCount pedidos realizados',
                          style: TextStyle(
                            color: palette.mutedText,
                            fontSize: 9.8.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: palette.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Text(
                      '$salesCount',
                      style: TextStyle(
                        color: palette.primary,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}