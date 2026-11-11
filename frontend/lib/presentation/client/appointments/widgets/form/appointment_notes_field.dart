import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/features/client/controllers/appointment_controller.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class AppointmentNotesField extends StatelessWidget {
  final AppointmentController controller;

  const AppointmentNotesField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.notes_rounded,
              color: RoleTheme.iconColorFor(
                Icons.notes_rounded,
                fallback: RoleTheme.iconInfo,
              ),
              size: 15.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              'Motivo de la consulta',
              style: TextStyle(
                color: palette.text,
                fontSize: 12.7.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller.notesController,
          maxLines: 3,
          minLines: 3,
          enabled: !controller.isSaving,
          style: TextStyle(
            color: palette.text,
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'Describe brevemente qué necesitas revisar...',
            hintStyle: TextStyle(
              fontSize: 12.2.sp,
              color: palette.mutedText,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: palette.background,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 11.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(
                color: RoleTheme.iconCalendar.withValues(alpha: 0.12),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(
                color: RoleTheme.iconCalendar.withValues(alpha: 0.12),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: const BorderSide(
                color: RoleTheme.iconCalendar,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}