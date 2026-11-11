import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:flutter/material.dart';

class NutritionistPatientStatusHelper {
  static Color statusColor(AppointmentStatus? status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return RoleTheme.nutritionist.primary;
      case AppointmentStatus.completed:
        return const Color(0xFF16A34A);
      case AppointmentStatus.cancelled:
        return const Color(0xFFEF4444);
      case AppointmentStatus.pending:
        return const Color(0xFFF59E0B);
      case AppointmentStatus.noShow:
        return const Color(0xFF64748B);
      default:
        return RoleTheme.nutritionist.primary;
    }
  }

  static String statusText(AppointmentStatus? status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return 'Paciente activo';
      case AppointmentStatus.completed:
        return 'Consulta completada';
      case AppointmentStatus.noShow:
        return 'No asistio';
      case AppointmentStatus.cancelled:
        return 'Cita cancelada';
      case AppointmentStatus.pending:
        return 'Pendiente';
      default:
        return 'Registrado';
    }
  }

  static String statusDescription(AppointmentStatus? status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return 'Tiene una cita confirmada contigo y se mantiene como paciente activo.';
      case AppointmentStatus.completed:
        return 'La última consulta registrada fue completada correctamente.';
      case AppointmentStatus.noShow:
        return 'La última cita se marcó como no asistida.';
      case AppointmentStatus.cancelled:
        return 'La última cita registrada fue cancelada.';
      case AppointmentStatus.pending:
        return 'Existe una cita pendiente de confirmación.';
      default:
        return 'Paciente registrado en la plataforma.';
    }
  }

  static String continuityText(AppointmentStatus? status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return 'Prepara la consulta y revisa si el paciente necesita indicaciones previas.';
      case AppointmentStatus.completed:
        return 'Puedes registrar recomendaciones o continuar el seguimiento en una nueva cita.';
      case AppointmentStatus.noShow:
        return 'Conviene contactar al paciente antes de programar una nueva consulta.';
      case AppointmentStatus.cancelled:
        return 'La atención quedó pausada hasta que se agende una nueva cita.';
      case AppointmentStatus.pending:
        return 'Espera la confirmación de la cita antes de iniciar el seguimiento.';
      default:
        return 'El seguimiento se actualizará cuando existan nuevas citas registradas.';
    }
  }
}








