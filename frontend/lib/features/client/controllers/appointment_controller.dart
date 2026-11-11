import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/core/services/auth/user_session_service.dart';
import 'package:emprendedor/core/utils/ecuador_time_utils.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';
import 'package:emprendedor/data/repositories/client/appointment_repository.dart';
import 'package:emprendedor/data/repositories/client/client_profile_repository.dart';
import 'package:emprendedor/data/repositories/nutritionist/nutritionist_availability_repository.dart';
import 'package:emprendedor/data/repositories/nutritionist/nutritionist_profile_repository.dart';

ConsultationMode mapConsultationMode(NutritionistConsultationMode mode) {
  switch (mode) {
    case NutritionistConsultationMode.presencial:
      return ConsultationMode.presencial;
    case NutritionistConsultationMode.virtual:
    case NutritionistConsultationMode.ambos:
      return ConsultationMode.virtual;
  }
}

class AppointmentController extends ChangeNotifier {
  final Logger _logger = Logger('AppointmentController');
  final AppointmentRepository _appointmentRepository = AppointmentRepository();
  final NutritionistProfileRepository _nutritionistRepository =
      NutritionistProfileRepository();
  final NutritionistAvailabilityRepository _availabilityRepository =
      NutritionistAvailabilityRepository();
  final ClientProfileRepository _clientProfileRepository =
      ClientProfileRepository();
  final UserSessionService _sessionService = UserSessionService();

  final notesController = TextEditingController();

  List<NutritionistProfileModel> _nutritionists = [];
  List<NutritionistProfileModel> get nutritionists => _nutritionists;
  StreamSubscription<List<NutritionistProfileModel>>?
  _nutritionistsSubscription;
  StreamSubscription<List<AppointmentModel>>? _appointmentsCountSubscription;
  String? _appointmentsCountUserId;

  List<String> _availableHours = [];
  List<String> get availableHours => List.unmodifiable(_availableHours);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingAvailableHours = false;
  bool get isLoadingAvailableHours => _isLoadingAvailableHours;

  bool _hasLoadedNutritionists = false;
  bool get hasLoadedNutritionists => _hasLoadedNutritionists;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _availabilityMessage;
  String? get availabilityMessage => _availabilityMessage;

  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  String? _selectedHour;
  String? get selectedHour => _selectedHour;

  int _appointmentsCount = 0;
  int get appointmentsCount => _appointmentsCount;

  Future<void> loadNutritionists({bool forceRefresh = false}) async {
    if (!forceRefresh && _hasLoadedNutritionists && _nutritionists.isNotEmpty) {
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      _nutritionists = await _nutritionistRepository.getAllNutritionists();
      _hasLoadedNutritionists = true;
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.severe('Error cargando nutricionistas', e, stackTrace);
      _hasLoadedNutritionists = true;
      _setError('No se pudieron cargar los nutricionistas.');
    } finally {
      _setLoading(false);
    }
  }

  void watchNutritionists() {
    if (_nutritionistsSubscription != null) return;

    _setLoading(!_hasLoadedNutritionists && _nutritionists.isEmpty);
    _setError(null);

    _nutritionistsSubscription = _nutritionistRepository
        .watchAllNutritionists()
        .listen(
          (nutritionists) {
            _nutritionists = nutritionists;
            _hasLoadedNutritionists = true;
            _setLoading(false);
            notifyListeners();
          },
          onError: (Object e, StackTrace stackTrace) {
            _logger.severe('Error escuchando nutricionistas', e, stackTrace);
            _hasLoadedNutritionists = true;
            _setLoading(false);
            _setError('No se pudieron cargar los nutricionistas.');
          },
        );
  }

  Future<void> loadAppointmentsCount() async {
    final uid = _sessionService.currentUserId();
    if (uid == null) return;

    try {
      _appointmentsCount = await _appointmentRepository
          .countAppointmentsForClient(uid);
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.severe('Error contando citas', e, stackTrace);
    }
  }

  Future<void> watchAppointmentsCount() async {
    final uid = _sessionService.currentUserId();
    if (uid == null) return;
    if (_appointmentsCountSubscription != null &&
        _appointmentsCountUserId == uid) {
      return;
    }

    await _appointmentsCountSubscription?.cancel();
    _appointmentsCountUserId = uid;
    _appointmentsCountSubscription = _appointmentRepository
        .getAppointmentsForClient(uid)
        .listen(
          (appointments) {
            _appointmentsCount = appointments.length;
            notifyListeners();
          },
          onError: (Object e, StackTrace stackTrace) {
            _logger.severe('Error escuchando contador de citas', e, stackTrace);
          },
        );
  }

  bool isAvailableWeekday(DateTime date) => true;

  Future<void> setSelectedDate(
    DateTime date, {
    NutritionistProfileModel? nutritionist,
  }) async {
    _selectedDate = date;
    _selectedHour = null;
    _availableHours = [];
    _availabilityMessage = nutritionist == null
        ? 'Selecciona un nutricionista para ver horarios disponibles.'
        : null;
    notifyListeners();

    if (nutritionist != null) {
      await loadAvailableHoursFor(nutritionist);
    }
  }

  Future<void> loadAvailableHoursFor(
    NutritionistProfileModel nutritionist,
  ) async {
    final date = _selectedDate;
    _availableHours = [];
    _selectedHour = null;

    if (date == null) {
      _availabilityMessage =
          'Selecciona una fecha para ver horarios disponibles.';
      notifyListeners();
      return;
    }

    _setLoadingAvailableHours(true);
    _availabilityMessage = null;

    try {
      final availability = await _availabilityRepository.getAvailability(
        nutritionist.userId,
      );

      if (availability == null || !availability.hasConfiguredDays) {
        _availabilityMessage =
            'Este nutricionista aún no configuró horarios disponibles.';
        _availableHours = [];
        return;
      }

      if (!availability.isDateEnabled(date)) {
        _availabilityMessage = 'No hay atención configurada para este día.';
        _availableHours = [];
        return;
      }

      final bookedHours = await _appointmentRepository
          .getBookedHoursForNutritionist(
            nutritionistUserId: nutritionist.userId,
            date: date,
          );
      _availableHours = availability.availableSlotsForDate(
        date,
        bookedHours: bookedHours,
      );

      _availabilityMessage = _availableHours.isEmpty
          ? 'No quedan horarios disponibles para esta fecha.'
          : null;
    } catch (e, stackTrace) {
      _logger.severe('Error cargando horarios disponibles', e, stackTrace);
      _availabilityMessage = 'No se pudieron cargar los horarios disponibles.';
      _availableHours = [];
    } finally {
      _setLoadingAvailableHours(false);
      notifyListeners();
    }
  }

  void setSelectedHour(String hour) {
    if (!_availableHours.contains(hour)) return;
    _selectedHour = hour;
    notifyListeners();
  }

  Future<AppointmentModel?> scheduleAppointment(
    NutritionistProfileModel nutritionist, {
    String? paymentIntentId,
    required int paidAmount,
    required String currency,
  }) async {
    final user = _sessionService.currentUser;
    final userId = user?.uid;
    final validationError = await _validateBeforeSchedule(
      userId: userId,
      paidAmount: paidAmount,
      nutritionist: nutritionist,
    );
    if (validationError != null) {
      _setError(validationError);
      return null;
    }

    _setSaving(true);
    _setError(null);

    try {
      final clientProfile = await _clientProfileRepository.getClientProfile(
        userId!,
      );
      final clientName = _resolveClientName(
        profileName: clientProfile?.name,
        displayName: user?.displayName,
      );
      final clientPhone = _nullableTrimString(clientProfile?.phone);
      final mode = mapConsultationMode(nutritionist.consultationMode);
      final hasPaymentIntent =
          paymentIntentId != null && paymentIntentId.trim().isNotEmpty;

      final appointment = AppointmentModel(
        clientUserId: userId,
        clientName: clientName,
        nutritionistUserId: nutritionist.userId,
        nutritionistName: nutritionist.name,
        nutritionistProfileImageUrl: _nullableTrimString(
          nutritionist.profileImageUrl,
        ),
        appointmentDate: Timestamp.fromDate(_buildAppointmentDateTime()),
        consultationMode: mode,
        meetingLink: null,
        meetingLinkStatus: mode == ConsultationMode.virtual
            ? 'pending_generation'
            : null,
        contactPhone: nutritionist.phone,
        clientContactPhone: clientPhone,
        appointmentAddress: mode == ConsultationMode.presencial
            ? nutritionist.consultationAddress
            : null,
        appointmentLatitude: mode == ConsultationMode.presencial
            ? nutritionist.consultationLatitude
            : null,
        appointmentLongitude: mode == ConsultationMode.presencial
            ? nutritionist.consultationLongitude
            : null,
        appointmentInstructions: _buildAppointmentInstructions(
          nutritionist: nutritionist,
          mode: mode,
        ),
        amount: paidAmount / 100,
        currency: currency,
        paymentIntentId: paymentIntentId,
        paymentStatus: hasPaymentIntent
            ? AppointmentPaymentStatus.paid
            : AppointmentPaymentStatus.pending,
        notes: _nullableTrim(notesController.text),
        status: AppointmentStatus.pending,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      final appointmentRef = await _appointmentRepository
          .createAppointmentIfSlotAvailable(appointment);
      final createdAppointment = appointment.copyWith(id: appointmentRef.id);

      await loadAppointmentsCount();
      _clearForm();
      return createdAppointment;
    } on AppointmentSlotUnavailableException catch (e) {
      _setError(e.message);
      await loadAvailableHoursFor(nutritionist);
      return null;
    } catch (e, stackTrace) {
      _logger.severe('Error guardando cita', e, stackTrace);
      _setError('No se pudo guardar la cita.');
      return null;
    } finally {
      _setSaving(false);
    }
  }

  Future<String?> _validateBeforeSchedule({
    required String? userId,
    required int paidAmount,
    required NutritionistProfileModel nutritionist,
  }) async {
    if (userId == null) return 'No hay usuario autenticado.';
    if (_selectedDate == null || _selectedHour == null) {
      return 'Selecciona fecha y hora para la cita.';
    }
    if (paidAmount <= 0) return 'El monto pagado no es válido.';

    if (!_availableHours.contains(_selectedHour)) {
      await loadAvailableHoursFor(nutritionist);
      if (!_availableHours.contains(_selectedHour)) {
        return 'Ese horario ya no está disponible. Elige otra hora.';
      }
    }

    return null;
  }

  String _resolveClientName({
    required String? profileName,
    required String? displayName,
  }) {
    if (profileName?.trim().isNotEmpty == true) {
      return profileName!.trim();
    }
    if (displayName?.trim().isNotEmpty == true) {
      return displayName!.trim();
    }
    return 'Cliente';
  }

  String? _buildAppointmentInstructions({
    required NutritionistProfileModel nutritionist,
    required ConsultationMode mode,
  }) {
    final customInstructions = nutritionist.consultationInstructions?.trim();
    if (customInstructions != null && customInstructions.isNotEmpty) {
      return customInstructions;
    }
    if (mode == ConsultationMode.virtual) {
      return _defaultVirtualInstructions();
    }
    return _defaultPresencialInstructions();
  }

  DateTime _buildAppointmentDateTime() {
    final parts = _selectedHour!.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return EcuadorTimeUtils.fromEcuadorLocalParts(
      year: _selectedDate!.year,
      month: _selectedDate!.month,
      day: _selectedDate!.day,
      hour: hour,
      minute: minute,
    );
  }

  String _defaultVirtualInstructions() {
    return 'El enlace de Meet se generará automáticamente y estará disponible cerca de la hora de la cita. '
        'Comparte exámenes o información adicional con el nutricionista si es necesario.';
  }

  String _defaultPresencialInstructions() {
    return 'Asiste 10 minutos antes de la cita. Lleva tus exámenes, recetas '
        'o información médica relevante si la tienes.';
  }

  String? _nullableTrim(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _nullableTrimString(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  void clearSchedulingSelection() {
    _selectedDate = null;
    _selectedHour = null;
    _availableHours = [];
    _availabilityMessage = null;
    notifyListeners();
  }

  void _clearForm() {
    notesController.clear();
    clearSchedulingSelection();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setLoadingAvailableHours(bool value) {
    if (_isLoadingAvailableHours == value) return;
    _isLoadingAvailableHours = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    if (_isSaving == value) return;
    _isSaving = value;
    notifyListeners();
  }

  void _setError(String? value) {
    if (_errorMessage == value) return;
    _errorMessage = value;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  Future<void> reset() async {
    await _nutritionistsSubscription?.cancel();
    await _appointmentsCountSubscription?.cancel();
    _nutritionistsSubscription = null;
    _appointmentsCountSubscription = null;
    _appointmentsCountUserId = null;
    _nutritionists = [];
    _availableHours = [];
    _hasLoadedNutritionists = false;
    _isLoading = false;
    _isLoadingAvailableHours = false;
    _isSaving = false;
    _errorMessage = null;
    _availabilityMessage = null;
    _selectedDate = null;
    _selectedHour = null;
    _appointmentsCount = 0;
    notesController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _nutritionistsSubscription?.cancel();
    _appointmentsCountSubscription?.cancel();
    notesController.dispose();
    super.dispose();
  }
}
