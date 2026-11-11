import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/data/repositories/client/appointment_repository.dart';

class NutritionistAppointmentsController extends ChangeNotifier {
  final Logger _logger = Logger('NutritionistAppointmentsController');
  final AppointmentRepository _repository = AppointmentRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<AppointmentModel> _appointments = [];
  List<AppointmentModel> get appointments => _appointments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasLoadedAppointments = false;
  bool get hasLoadedAppointments => _hasLoadedAppointments;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _nutritionistUserId;
  String? get nutritionistUserId => _nutritionistUserId;

  StreamSubscription<List<AppointmentModel>>? _subscription;

  Future<void> setNutritionistUserId(String? userId) async {
    if (_nutritionistUserId == userId) return;

    await _subscription?.cancel();
    _subscription = null;

    _nutritionistUserId = userId;

    if (_nutritionistUserId == null || _nutritionistUserId!.trim().isEmpty) {
      await reset();
      return;
    }

    await loadAppointments();
  }

  Future<void> initUser() async {
    final user = _auth.currentUser;
    await setNutritionistUserId(user?.uid);
  }

  Future<void> loadAppointments() async {
    final userId = _nutritionistUserId ?? _auth.currentUser?.uid;

    if (userId == null || userId.trim().isEmpty) {
      _appointments = [];
      _errorMessage = 'No hay nutricionista autenticado';
      _isLoading = false;
      _hasLoadedAppointments = true;
      notifyListeners();
      return;
    }

    _nutritionistUserId = userId;

    _setLoading(true);
    _setError(null);

    try {
      await _subscription?.cancel();
      _subscription = null;

      _subscription = _repository
          .getAppointmentsForNutritionist(userId)
          .listen(
            (appointmentsList) {
              _appointments = appointmentsList;
              _hasLoadedAppointments = true;
              _setLoading(false);
              notifyListeners();
            },
            onError: (error, stackTrace) {
              _logger.severe('Error cargando citas', error, stackTrace);
              _appointments = [];
              _hasLoadedAppointments = true;
              _setError('No se pudieron cargar las citas');
              _setLoading(false);
            },
          );
    } catch (e, st) {
      _logger.severe('Error cargando citas', e, st);
      _appointments = [];
      _hasLoadedAppointments = true;
      _setError('No se pudieron cargar las citas');
      _setLoading(false);
    }
  }

  Future<void> updateStatus(
    String appointmentId,
    AppointmentStatus status,
  ) async {
    final userId = _nutritionistUserId ?? _auth.currentUser?.uid;

    if (userId == null || userId.trim().isEmpty) {
      _setError('No autorizado');
      return;
    }

    try {
      _setError(null);
      await _repository.updateAppointmentStatusForNutritionist(
        appointmentId,
        status,
        userId,
      );
    } catch (e, st) {
      _logger.severe('Error actualizando estado', e, st);
      _setError('No se pudo actualizar el estado. ${friendlyErrorMessage(e)}');
    }
  }

  Future<void> reset() async {
    await _subscription?.cancel();
    _subscription = null;

    _appointments = [];
    _errorMessage = null;
    _isLoading = false;
    _hasLoadedAppointments = false;
    _nutritionistUserId = null;

    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    if (_errorMessage == value) return;
    _errorMessage = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
