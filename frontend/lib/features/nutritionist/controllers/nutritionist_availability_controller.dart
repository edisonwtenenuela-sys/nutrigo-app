import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/core/services/auth/user_session_service.dart';
import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_availability_model.dart';
import 'package:emprendedor/data/repositories/nutritionist/nutritionist_availability_repository.dart';

class NutritionistAvailabilityController extends ChangeNotifier {
  NutritionistAvailabilityController({
    NutritionistAvailabilityRepository? repository,
    UserSessionService? sessionService,
  }) : _repository = repository ?? NutritionistAvailabilityRepository(),
       _sessionService = sessionService ?? UserSessionService();

  final NutritionistAvailabilityRepository _repository;
  final UserSessionService _sessionService;
  final Logger _logger = Logger('NutritionistAvailabilityController');

  static const slotDurationOptions = [30, 45, 60];
  static const timeOptions = [
    '06:00',
    '07:00',
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
  ];

  NutritionistAvailabilityModel? _availability;
  NutritionistAvailabilityModel? get availability => _availability;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  Future<void> loadAvailability() async {
    final userId = _sessionService.currentUserId();
    if (userId == null) {
      _setError('No hay una sesión activa.');
      return;
    }

    _setLoading(true);
    _setError(null);
    _successMessage = null;

    try {
      _availability =
          await _repository.getAvailability(userId) ??
          NutritionistAvailabilityModel.empty(userId);
      notifyListeners();
    } catch (error, stackTrace) {
      _logger.severe('Error cargando disponibilidad', error, stackTrace);
      _setError(
        'No se pudo cargar tu disponibilidad. ${friendlyErrorMessage(error)}',
      );
    } finally {
      _setLoading(false);
    }
  }

  void toggleDay(String dayKey, bool enabled) {
    final current = _availability;
    if (current == null) return;

    final days = Map<String, NutritionistAvailabilityDay>.from(current.days);
    final day = days[dayKey] ?? const NutritionistAvailabilityDay.disabled();
    days[dayKey] = day.copyWith(enabled: enabled);
    _availability = current.copyWith(days: days);
    _clearMessages();
    notifyListeners();
  }

  void updateStartTime(String dayKey, String value) {
    _updateDay(dayKey, (day) => day.copyWith(startTime: value));
  }

  void updateEndTime(String dayKey, String value) {
    _updateDay(dayKey, (day) => day.copyWith(endTime: value));
  }

  void updateSlotDuration(int value) {
    final current = _availability;
    if (current == null || !slotDurationOptions.contains(value)) return;
    _availability = current.copyWith(slotDurationMinutes: value);
    _clearMessages();
    notifyListeners();
  }

  Future<bool> saveAvailability() async {
    final current = _availability;
    if (current == null) return false;

    final validationError = _validate(current);
    if (validationError != null) {
      _setError(validationError);
      return false;
    }

    _setSaving(true);
    _setError(null);
    _successMessage = null;

    try {
      await _repository.saveAvailability(current);
      _successMessage = 'Disponibilidad guardada correctamente.';
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      _logger.severe('Error guardando disponibilidad', error, stackTrace);
      _setError(
        'No se pudo guardar tu disponibilidad. ${friendlyErrorMessage(error)}',
      );
      return false;
    } finally {
      _setSaving(false);
    }
  }

  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  void _updateDay(
    String dayKey,
    NutritionistAvailabilityDay Function(NutritionistAvailabilityDay day)
    update,
  ) {
    final current = _availability;
    if (current == null) return;

    final days = Map<String, NutritionistAvailabilityDay>.from(current.days);
    final day = days[dayKey] ?? const NutritionistAvailabilityDay.disabled();
    days[dayKey] = update(day);
    _availability = current.copyWith(days: days);
    _clearMessages();
    notifyListeners();
  }

  String? _validate(NutritionistAvailabilityModel value) {
    if (!value.hasConfiguredDays) {
      return 'Activa al menos un día de atención.';
    }

    for (final entry in value.days.entries) {
      final day = entry.value;
      if (!day.enabled) continue;

      final start = _minutesFromTime(day.startTime);
      final end = _minutesFromTime(day.endTime);
      final label =
          NutritionistAvailabilityModel.weekdayLabels[entry.key] ?? 'Día';

      if (start == null || end == null || end <= start) {
        return 'Revisa el horario de $label.';
      }

      if (end - start < value.slotDurationMinutes) {
        return 'El horario de $label debe cubrir al menos un bloque de atención.';
      }
    }

    return null;
  }

  int? _minutesFromTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
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

  void reset() {
    _availability = null;
    _isLoading = false;
    _isSaving = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
