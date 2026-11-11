import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/shared/widgets/buttons/app_action_button.dart';

class EmptyAppointmentsState extends StatelessWidget {
  final VoidCallback onSchedule;

  const EmptyAppointmentsState({
    super.key,
    required this.onSchedule,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return SafeArea(
      top: false,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 108.w,
                height: 108.w,
                decoration: const BoxDecoration(
                  color: RoleTheme.brandBadgeBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  size: 54.sp,
                  color: RoleTheme.iconCalendar,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Aún no tienes citas agendadas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Cuando reserves una consulta con un nutricionista, aparecerá aquí con la fecha, hora y estado de la cita.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.mutedText,
                  height: 1.35,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 22.h),
              ClientActionButton(
                label: 'Agendar una cita',
                icon: Icons.add_rounded,
                height: 46.h,
                fontSize: 13.5.sp,
                onPressed: onSchedule,
              ),
            ],
          ),
        ),
      ),
    );
  }
}