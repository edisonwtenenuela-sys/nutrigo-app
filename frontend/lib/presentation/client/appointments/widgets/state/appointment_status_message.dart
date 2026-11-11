import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';

class AppointmentStatusMessage extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentStatusMessage({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    String? message;
    Color color = palette.mutedText;

    if (appointment.isVirtual) {
      if (appointment.hasMeetingLink) {
        message = appointment.status == AppointmentStatus.confirmed
            ? 'La videollamada ya está disponible para la hora de tu cita.'
            : 'El enlace estará disponible cuando el nutricionista confirme.';
      } else if (appointment.isMeetingLinkPending) {
        message = 'Estamos preparando el enlace de videollamada.';
      } else if (appointment.needsManualMeetingLink) {
        message = 'El enlace de videollamada requiere configuración.';
      } else {
        message = 'El enlace aparecerá cuando esté disponible.';
      }

      color = palette.mutedText;
    }

    if (appointment.status == AppointmentStatus.pending) {
      message = 'Esperando confirmación del nutricionista.';
      color = RoleTheme.iconWarning;
    }

    if (appointment.status == AppointmentStatus.completed) {
      message = 'Tu consulta fue completada.';
      color = RoleTheme.iconValidation;
    }

    if (appointment.status == AppointmentStatus.cancelled) {
      message = 'La cita fue cancelada.';
      color = RoleTheme.iconDanger;
    }

    if (appointment.status == AppointmentStatus.noShow) {
      message = 'El nutricionista marcó esta cita como no asistida.';
      color = palette.mutedText;
    }

    if (appointment.isPresencial &&
        appointment.status != AppointmentStatus.cancelled &&
        (appointment.appointmentAddress?.trim().isNotEmpty ?? false)) {
      message = 'Toca para ver la ubicación de la consulta.';
      color = palette.mutedText;
    }

    if (message == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Text(
        message,
        style: TextStyle(
          color: color,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
      ),
    );
  }
}