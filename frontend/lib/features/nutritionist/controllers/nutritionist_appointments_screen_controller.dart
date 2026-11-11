import 'package:flutter/material.dart';

import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/features/nutritionist/controllers/nutritionist_appointments_controller.dart';
import 'package:emprendedor/core/feedback/app_feedback_level.dart';

enum NutritionistAppointmentFilter { all, pending, confirmed, completed }

enum NutritionistAppointmentsUiState { loading, error, empty, content }

class NutritionistAppointmentStatusResult {
  const NutritionistAppointmentStatusResult({
    required this.success,
    required this.type,
    required this.title,
    required this.message,
  });

  final bool success;
  final AppFeedbackLevel type;
  final String title;
  final String message;
}

class NutritionistAppointmentsScreenController extends ChangeNotifier {
  NutritionistAppointmentFilter selectedFilter =
      NutritionistAppointmentFilter.all;

  List<({String label, NutritionistAppointmentFilter value})>
  get filterOptions => [
    (label: 'Todas', value: NutritionistAppointmentFilter.all),
    (label: 'Pendientes', value: NutritionistAppointmentFilter.pending),
    (label: 'Confirmadas', value: NutritionistAppointmentFilter.confirmed),
    (label: 'Completadas', value: NutritionistAppointmentFilter.completed),
  ];

  NutritionistAppointmentsUiState resolveUiState(
    NutritionistAppointmentsController controller,
  ) {
    if (!controller.hasLoadedAppointments && controller.appointments.isEmpty) {
      return NutritionistAppointmentsUiState.loading;
    }

    if (controller.isLoading) {
      return NutritionistAppointmentsUiState.loading;
    }
    if (controller.errorMessage != null && controller.appointments.isEmpty) {
      return NutritionistAppointmentsUiState.error;
    }
    if (controller.appointments.isEmpty) {
      return NutritionistAppointmentsUiState.empty;
    }
    return NutritionistAppointmentsUiState.content;
  }

  void setFilter(NutritionistAppointmentFilter value) {
    if (selectedFilter == value) return;
    selectedFilter = value;
    notifyListeners();
  }

  List<AppointmentModel> filteredAppointments(
    List<AppointmentModel> appointments,
  ) {
    switch (selectedFilter) {
      case NutritionistAppointmentFilter.pending:
        return appointments
            .where((item) => item.status == AppointmentStatus.pending)
            .toList();
      case NutritionistAppointmentFilter.confirmed:
        return appointments
            .where((item) => item.status == AppointmentStatus.confirmed)
            .toList();
      case NutritionistAppointmentFilter.completed:
        return appointments
            .where((item) => item.status == AppointmentStatus.completed)
            .toList();
      case NutritionistAppointmentFilter.all:
        return appointments;
    }
  }

  bool needsConfirmation(AppointmentStatus status) {
    return status == AppointmentStatus.noShow ||
        status == AppointmentStatus.completed ||
        status == AppointmentStatus.cancelled;
  }

  String confirmationMessage(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.completed:
        return '\u00BFConfirmas que el cliente asisti\u00F3 y la cita fue completada?';
      case AppointmentStatus.noShow:
        return '\u00BFConfirmas que el cliente no asisti\u00F3 a la cita?';
      case AppointmentStatus.cancelled:
        return '\u00BFSeguro que deseas cancelar esta cita?';
      default:
        return '\u00BFDeseas actualizar esta cita?';
    }
  }

  Future<NutritionistAppointmentStatusResult> updateAppointmentStatus(
    NutritionistAppointmentsController controller,
    AppointmentModel appointment,
    AppointmentStatus status,
  ) async {
    final appointmentId = appointment.id;

    if (appointmentId == null || appointmentId.isEmpty) {
      return const NutritionistAppointmentStatusResult(
        success: false,
        type: AppFeedbackLevel.error,
        title: 'Cita no disponible',
        message: 'No se pudo identificar la cita.',
      );
    }

    await controller.updateStatus(appointmentId, status);

    if (controller.errorMessage != null) {
      return NutritionistAppointmentStatusResult(
        success: false,
        type: AppFeedbackLevel.error,
        title: 'No se pudo actualizar',
        message: controller.errorMessage!,
      );
    }

    return NutritionistAppointmentStatusResult(
      success: true,
      type: AppFeedbackLevel.success,
      title: 'Cita actualizada',
      message: 'Estado actualizado a: ${status.label}',
    );
  }
}








