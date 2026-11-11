import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class StatisticsDateRangeCard extends StatelessWidget {
  final DateTimeRange? range;
  final VoidCallback onTap;

  const StatisticsDateRangeCard({
    super.key,
    required this.range,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final rangeText = range == null
        ? 'Seleccionar rango'
        : '${DateFormat('dd MMM', 'es_ES').format(range!.start)} - ${DateFormat('dd MMM yyyy', 'es_ES').format(range!.end)}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17.r),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 10.h,
          ),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(17.r),
            border: Border.all(
              color: palette.primary.withValues(alpha: 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: palette.primary.withValues(alpha: 0.035),
                blurRadius: 12.r,
                offset: Offset(0, 5.h),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.date_range_rounded,
                  color: RoleTheme.iconColorFor(
                    Icons.date_range_rounded,
                    fallback: palette.primary,
                  ),
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Periodo de análisis',
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 11.4.sp,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      rangeText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.mutedText,
                        fontSize: 10.8.sp,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: palette.primary,
                size: 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}