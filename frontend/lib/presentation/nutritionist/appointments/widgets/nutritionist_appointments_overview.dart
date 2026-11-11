import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/features/nutritionist/helpers/nutritionist_appointments_summary_helper.dart';

class NutritionistAppointmentsOverview extends StatelessWidget {
  final List<AppointmentModel> appointments;

  const NutritionistAppointmentsOverview({
    super.key,
    required this.appointments,
  });

  int _count(AppointmentStatus status) {
    return NutritionistAppointmentsSummaryHelper.countByStatus(
      appointments,
      status,
    );
  }

  List<({String value, String label, Color color})> _buildCounters(
      RolePalette palette,
      ) {
    return [
      (
      value: '${_count(AppointmentStatus.pending)}',
      label: 'Pend.',
      color: RoleTheme.iconWarning,
      ),
      (
      value: '${_count(AppointmentStatus.completed)}',
      label: 'Comp.',
      color: RoleTheme.iconValidation,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;
    final counters = _buildCounters(palette);

    return Container(
      margin: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 0),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: RoleTheme.iconColorFor(
                Icons.calendar_month_rounded,
                fallback: palette.primary,
              ),
              size: 23.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agenda profesional',
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${appointments.length} citas registradas',
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 11.4.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < counters.length; i++) ...[
            _MiniCounter(
              value: counters[i].value,
              label: counters[i].label,
              color: counters[i].color,
            ),
            if (i < counters.length - 1) SizedBox(width: 8.w),
          ],
        ],
      ),
    );
  }
}

class _MiniCounter extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MiniCounter({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      padding: EdgeInsets.symmetric(vertical: 7.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}