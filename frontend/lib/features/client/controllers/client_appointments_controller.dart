import 'package:flutter/material.dart';

import 'package:emprendedor/core/services/auth/user_session_service.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/data/repositories/client/appointment_repository.dart';
import 'package:emprendedor/features/client/helpers/client_appointments_helper.dart';

class ClientAppointmentsSummary {
  const ClientAppointmentsSummary({
    required this.total,
    required this.pending,
    required this.completed,
  });

  final int total;
  final int pending;
  final int completed;
}

class ClientAppointmentsController extends ChangeNotifier {
  ClientAppointmentsController({
    AppointmentRepository? repository,
    UserSessionService? sessionService,
  }) : _repository = repository ?? AppointmentRepository(),
       _sessionService = sessionService ?? UserSessionService();

  final AppointmentRepository _repository;
  final UserSessionService _sessionService;

  String? get currentUserId => _sessionService.currentUserId();

  Stream<List<AppointmentModel>> appointmentsStream(String userId) {
    return _repository.getAppointmentsForClient(userId);
  }

  ClientAppointmentsSummary buildSummary(List<AppointmentModel> appointments) {
    return ClientAppointmentsSummary(
      total: appointments.length,
      pending: ClientAppointmentsHelper.countByStatus(
        appointments,
        AppointmentStatus.pending,
      ),
      completed: ClientAppointmentsHelper.countByStatus(
        appointments,
        AppointmentStatus.completed,
      ),
    );
  }

  Future<void> refreshAppointments() async {
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
}








