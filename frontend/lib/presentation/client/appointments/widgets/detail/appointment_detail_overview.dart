import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';

class AppointmentDetailOverview extends StatelessWidget {
  final AppointmentModel appointment;
  final DateTime date;

  const AppointmentDetailOverview({
    super.key,
    required this.appointment,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: RoleTheme.iconCalendar.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _OverviewItem(
              icon: Icons.today_rounded,
              label: 'Día',
              value: DateFormat('dd MMM', 'es').format(date),
            ),
          ),
          const _OverviewDivider(),
          Expanded(
            child: _OverviewItem(
              icon: Icons.schedule_rounded,
              label: 'Hora',
              value: DateFormat('HH:mm').format(date),
            ),
          ),
          const _OverviewDivider(),
          Expanded(
            child: _OverviewItem(
              icon: appointment.isVirtual
                  ? Icons.video_call_rounded
                  : Icons.location_on_rounded,
              label: 'Modo',
              value: appointment.consultationMode.label,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewDivider extends StatelessWidget {
  const _OverviewDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42.h,
      margin: EdgeInsets.symmetric(horizontal: 7.w),
      color: RoleTheme.iconCalendar.withValues(alpha: 0.10),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _OverviewItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Column(
      children: [
        Icon(
          icon,
          color: RoleTheme.iconColorFor(
            icon,
            fallback: RoleTheme.iconCalendar,
          ),
          size: 17.sp,
        ),
        SizedBox(height: 5.h),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.mutedText,
            fontSize: 9.5.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.text,
            fontSize: 11.2.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}