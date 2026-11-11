import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/data/models/client/client_profile_model.dart';
import 'package:emprendedor/data/repositories/client/appointment_repository.dart';
import 'package:emprendedor/data/repositories/client/client_profile_repository.dart';

class NutritionistPatientsController extends ChangeNotifier {
  final AppointmentRepository _repository = AppointmentRepository();
  final ClientProfileRepository _clientProfileRepository =
      ClientProfileRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _patients = [];
  List<Map<String, dynamic>> get patients => _patients;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasLoadedOnce = false;
  bool get hasLoadedOnce => _hasLoadedOnce;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription<List<AppointmentModel>>? _subscription;
  bool _disposed = false;

  Future<void> loadPatients() async {
    final user = _auth.currentUser;

    if (user == null) {
      _patients = [];
      _errorMessage = 'No hay nutricionista autenticado.';
      _isLoading = false;
      _hasLoadedOnce = true;
      notifyListeners();
      return;
    }

    await _subscription?.cancel();
    _subscription = null;

    _isLoading = !_hasLoadedOnce;
    _errorMessage = null;
    notifyListeners();

    try {
      _subscription = _repository
          .getAppointmentsForNutritionist(user.uid)
          .listen(
            (appointments) {
              final Map<String, Map<String, dynamic>> uniquePatients = {};

              for (final appt in appointments) {
                final isAcceptedPatient =
                    appt.status == AppointmentStatus.confirmed ||
                    appt.status == AppointmentStatus.completed;

                if (!isAcceptedPatient) continue;
                if (appt.clientUserId.trim().isEmpty) continue;

                final current = uniquePatients[appt.clientUserId];
                final isNewPatient = current == null;
                final currentDate = current?['lastDate'] as dynamic;
                final isLatest =
                    isNewPatient ||
                    appt.appointmentDate.toDate().isAfter(
                      currentDate.toDate() as DateTime,
                    );

                uniquePatients[appt.clientUserId] = {
                  'id': appt.clientUserId,
                  'name': appt.clientName.trim().isNotEmpty
                      ? appt.clientName
                      : current?['name'] ?? 'Paciente',
                  'lastDate': isLatest
                      ? appt.appointmentDate
                      : current['lastDate'],
                  'status': isLatest ? appt.status : current['status'],
                  'profileImageUrl': isLatest
                      ? appt.clientProfileImageUrl
                      : current['profileImageUrl'],
                  'appointmentCount':
                      (current?['appointmentCount'] as int? ?? 0) + 1,
                  'completedCount':
                      (current?['completedCount'] as int? ?? 0) +
                      (appt.status == AppointmentStatus.completed ? 1 : 0),
                  'confirmedCount':
                      (current?['confirmedCount'] as int? ?? 0) +
                      (appt.status == AppointmentStatus.confirmed ? 1 : 0),
                };
              }

              _patients = uniquePatients.values.toList();
              _patients.sort((a, b) => b['lastDate'].compareTo(a['lastDate']));

              _hasLoadedOnce = true;
              _isLoading = false;
              _errorMessage = null;
              notifyListeners();

              _hydrateClientProfiles(_patients);
            },
            onError: (error, stackTrace) {
              _patients = [];
              _errorMessage = 'No se pudieron cargar los pacientes.';
              _hasLoadedOnce = true;
              _isLoading = false;
              notifyListeners();
            },
          );
    } catch (_) {
      _patients = [];
      _errorMessage = 'No se pudieron cargar los pacientes.';
      _hasLoadedOnce = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reset() async {
    await _subscription?.cancel();
    _subscription = null;

    _patients = [];
    _errorMessage = null;
    _isLoading = false;
    _hasLoadedOnce = false;

    notifyListeners();
  }

  Future<void> _hydrateClientProfiles(
    List<Map<String, dynamic>> sourcePatients,
  ) async {
    final ids = sourcePatients
        .map((patient) => patient['id']?.toString() ?? '')
        .where((id) => id.trim().isNotEmpty)
        .toSet()
        .toList();

    if (ids.isEmpty) return;

    final profiles = await Future.wait(
      ids.map(_clientProfileRepository.getClientProfile),
    );

    if (_disposed) return;

    final profileById = {
      for (final profile in profiles.whereType<ClientProfileModel>())
        profile.userId: profile,
    };

    var changed = false;

    _patients = _patients.map((patient) {
      final id = patient['id']?.toString() ?? '';
      final profile = profileById[id];

      if (profile == null) return patient;

      changed = true;

      return {
        ...patient,
        'name': profile.name.trim().isNotEmpty ? profile.name : patient['name'],
        'profileImageUrl': profile.profileImageUrl,
        'phone': profile.phone,
        'age': profile.age,
        'gender': profile.gender,
        'weight': profile.weight,
        'height': profile.height,
        'dietaryGoal': profile.dietaryGoal,
        'allergies': profile.allergies,
        'medicalConditions': profile.medicalConditions,
      };
    }).toList();

    if (changed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}








