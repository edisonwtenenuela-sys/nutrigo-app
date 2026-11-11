import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/client/controllers/appointment_controller.dart';

class AppointmentDateTimeSelector extends StatelessWidget {
  final AppointmentController controller;
  final VoidCallback onPickDate;

  const AppointmentDateTimeSelector({
    super.key,
    required this.controller,
    required this.onPickDate,
  });

  Widget _buildDateSelector({
    required RolePalette palette,
    required DateTime? selectedDate,
    required String dateText,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(15.r),
      onTap: controller.isSaving ? null : onPickDate,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: RoleTheme.iconCalendar.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: RoleTheme.iconCalendar.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                color: RoleTheme.iconColorFor(
                  Icons.calendar_month_rounded,
                  fallback: RoleTheme.iconCalendar,
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
                    'Fecha de la cita',
                    style: TextStyle(
                      color: palette.mutedText,
                      fontSize: 10.4.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    dateText,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selectedDate == null
                          ? palette.mutedText
                          : palette.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 12.5.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: RoleTheme.iconColorFor(
                Icons.chevron_right_rounded,
                fallback: RoleTheme.iconInfo,
              ),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoursStatus(RolePalette palette, String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: RoleTheme.iconInfo.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: RoleTheme.iconInfo.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: RoleTheme.iconColorFor(
              Icons.info_outline_rounded,
              fallback: RoleTheme.iconInfo,
            ),
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: palette.mutedText,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingHours(RolePalette palette) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: RoleTheme.iconCalendar.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: RoleTheme.iconCalendar.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16.w,
            height: 16.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: RoleTheme.iconCalendar,
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            'Cargando horarios disponibles...',
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableHoursChips(RolePalette palette) {
    if (controller.selectedDate == null) {
      return _buildHoursStatus(
        palette,
        'Selecciona una fecha para ver horarios disponibles.',
      );
    }

    if (controller.isLoadingAvailableHours) {
      return _buildLoadingHours(palette);
    }

    if (controller.availableHours.isEmpty) {
      return _buildHoursStatus(
        palette,
        controller.availabilityMessage ??
            'No hay horarios disponibles para esta fecha.',
      );
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: controller.availableHours.map((hour) {
        final isSelected = controller.selectedHour == hour;

        return ChoiceChip(
          label: Text(hour),
          selected: isSelected,
          showCheckmark: false,
          onSelected: (_) => controller.setSelectedHour(hour),
          selectedColor: RoleTheme.iconCalendar,
          backgroundColor: RoleTheme.iconCalendar.withValues(alpha: 0.05),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : RoleTheme.iconCalendar,
            fontWeight: FontWeight.w900,
            fontSize: 10.5.sp,
          ),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(
              color: RoleTheme.iconCalendar.withValues(alpha: 0.15),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final selectedDate = controller.selectedDate;
    final dateText = selectedDate == null
        ? 'Seleccionar fecha'
        : DateFormat('EEE, dd MMM yyyy', 'es').format(selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateSelector(
          palette: palette,
          selectedDate: selectedDate,
          dateText: dateText,
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              color: RoleTheme.iconColorFor(
                Icons.schedule_rounded,
                fallback: RoleTheme.iconCalendar,
              ),
              size: 15.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              'Horarios disponibles',
              style: TextStyle(
                color: palette.text,
                fontWeight: FontWeight.w900,
                fontSize: 12.7.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        _buildAvailableHoursChips(palette),
      ],
    );
  }
}