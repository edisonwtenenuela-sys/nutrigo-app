import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/features/nutritionist/controllers/nutritionist_appointments_screen_controller.dart';
import 'package:emprendedor/presentation/nutritionist/appointments/widgets/appointment_status_actions.dart';
import 'package:emprendedor/presentation/nutritionist/appointments/widgets/nutritionist_card/nutritionist_appointment_actions.dart';
import 'package:emprendedor/presentation/nutritionist/appointments/widgets/nutritionist_card/nutritionist_appointment_header.dart';
import 'package:emprendedor/presentation/nutritionist/appointments/widgets/nutritionist_card/nutritionist_appointment_info_box.dart';
import 'package:emprendedor/presentation/nutritionist/appointments/widgets/nutritionist_card/nutritionist_appointment_info_chip.dart';

typedef NutritionistAppointmentStatusHandler =
    Future<NutritionistAppointmentStatusResult?> Function(
      AppointmentStatus status,
    );
typedef NutritionistAppointmentSheetStatusHandler =
    Future<void> Function(AppointmentStatus status);

class NutritionistAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final NutritionistAppointmentStatusHandler onUpdateStatus;
  final Future<void> Function(NutritionistAppointmentStatusResult result)
  onStatusFeedback;

  const NutritionistAppointmentCard({
    super.key,
    required this.appointment,
    required this.onUpdateStatus,
    required this.onStatusFeedback,
  });

  Color get _statusColor {
    switch (appointment.status) {
      case AppointmentStatus.pending:
        return RoleTheme.iconWarning;
      case AppointmentStatus.confirmed:
        return RoleTheme.nutritionist.primary;
      case AppointmentStatus.completed:
        return RoleTheme.iconValidation;
      case AppointmentStatus.cancelled:
        return RoleTheme.iconDanger;
      case AppointmentStatus.noShow:
        return RoleTheme.nutritionist.mutedText;
    }
  }

  Widget _buildCompactChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      height: 27.h,
      padding: EdgeInsets.symmetric(horizontal: 9.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: color),
          SizedBox(width: 5.w),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  void _openDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _NutritionistAppointmentDetailSheet(
          appointment: appointment,
          onUpdateStatus: (status) async {
            final result = await onUpdateStatus(status);
            if (result == null) return;

            if (result.success && sheetContext.mounted) {
              Navigator.of(sheetContext).pop();
              await Future<void>.delayed(const Duration(milliseconds: 120));
            }

            if (context.mounted) {
              await onStatusFeedback(result);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;
    final statusColor = _statusColor;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: () => _openDetails(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 4.h, color: statusColor),
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NutritionistAppointmentHeader(appointment: appointment),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCompactChip(
                              icon: appointment.isVirtual
                                  ? Icons.video_call_rounded
                                  : Icons.location_on_rounded,
                              text: appointment.consultationMode.label,
                              color: palette.primary,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: _buildCompactChip(
                              icon: Icons.payments_rounded,
                              text: appointment.paymentStatus.label,
                              color:
                                  appointment.paymentStatus ==
                                      AppointmentPaymentStatus.paid
                                  ? RoleTheme.iconValidation
                                  : RoleTheme.iconWarning,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 9.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Revisar y gestionar cita',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.mutedText,
                                fontSize: 10.6.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Ver detalle',
                            style: TextStyle(
                              color: palette.primary,
                              fontSize: 10.8.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: palette.primary,
                            size: 16.sp,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NutritionistAppointmentDetailSheet extends StatelessWidget {
  final AppointmentModel appointment;
  final NutritionistAppointmentSheetStatusHandler onUpdateStatus;

  const _NutritionistAppointmentDetailSheet({
    required this.appointment,
    required this.onUpdateStatus,
  });

  Widget _buildOptionalInfoBox({
    required String? text,
    required IconData icon,
  }) {
    if (text?.trim().isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(height: 8.h),
        NutritionistAppointmentInfoBox(icon: icon, text: text!),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      minChildSize: 0.52,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: palette.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(16.w, 9.h, 16.w, 18.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: palette.mutedText.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: palette.primary.withValues(alpha: 0.05),
                        blurRadius: 16.r,
                        offset: Offset(0, 6.h),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NutritionistAppointmentHeader(appointment: appointment),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Expanded(
                            child: NutritionistAppointmentInfoChip(
                              icon: appointment.isVirtual
                                  ? Icons.video_call_rounded
                                  : Icons.location_on_rounded,
                              title: 'Modalidad',
                              text: appointment.consultationMode.label,
                              color: palette.primary,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: NutritionistAppointmentInfoChip(
                              icon: Icons.payments_rounded,
                              title: 'Pago',
                              text: appointment.paymentStatus.label,
                              color:
                                  appointment.paymentStatus ==
                                      AppointmentPaymentStatus.paid
                                  ? RoleTheme.iconValidation
                                  : RoleTheme.iconWarning,
                            ),
                          ),
                        ],
                      ),
                      _buildOptionalInfoBox(
                        text: appointment.appointmentInstructions,
                        icon: Icons.info_outline_rounded,
                      ),
                      _buildOptionalInfoBox(
                        text: appointment.notes,
                        icon: Icons.notes_rounded,
                      ),
                      SizedBox(height: 10.h),
                      NutritionistAppointmentActions(appointment: appointment),
                      SizedBox(height: 12.h),
                      AppointmentStatusActions(
                        currentStatus: appointment.status,
                        appointmentHasPassed: appointment.hasPassed,
                        onUpdateStatus: (status) => onUpdateStatus(status),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
