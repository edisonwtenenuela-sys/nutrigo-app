import 'package:flutter/material.dart';

import 'package:emprendedor/core/services/payments/appointment_payment_service.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';
import 'package:emprendedor/features/client/controllers/appointment_controller.dart';
import 'package:emprendedor/features/client/helpers/appointment_date_helper.dart';

class ScheduleAppointmentFeedback {
  const ScheduleAppointmentFeedback({
    required this.message,
    this.title = 'Aviso',
    this.isError = false,
  });

  final String message;
  final String title;
  final bool isError;
}

class ScheduleAppointmentResult {
  const ScheduleAppointmentResult({
    required this.message,
    required this.appointment,
  });

  final String message;
  final AppointmentModel appointment;
}

enum ScheduleAppointmentUiState { loading, content }

class ScheduleAppointmentController extends ChangeNotifier {
  ScheduleAppointmentController({AppointmentPaymentService? paymentService})
    : _paymentService = paymentService ?? AppointmentPaymentService();

  final AppointmentPaymentService _paymentService;

  NutritionistProfileModel? selectedNutritionist;
  NutritionistConsultationMode? selectedMode;
  bool isPaymentFlowActive = false;

  bool _disposed = false;

  static ScheduleAppointmentUiState resolveUiState(
    AppointmentController controller,
  ) {
    if (!controller.hasLoadedNutritionists &&
        controller.nutritionists.isEmpty) {
      return ScheduleAppointmentUiState.loading;
    }

    if (controller.isLoading) return ScheduleAppointmentUiState.loading;
    return ScheduleAppointmentUiState.content;
  }

  static DateTime initialSchedulingDate(DateTime now) {
    return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  }

  static DateTime maxSchedulingDate(DateTime now) {
    return AppointmentDateHelper.maxSchedulingDate(now);
  }

  static bool canSelectDate(DateTime date) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final selected = DateTime(date.year, date.month, date.day);
    return !selected.isBefore(startOfToday);
  }

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  void selectNutritionist(NutritionistProfileModel nutritionist) {
    selectedNutritionist = nutritionist;
    selectedMode =
        nutritionist.consultationMode == NutritionistConsultationMode.ambos
        ? NutritionistConsultationMode.virtual
        : nutritionist.consultationMode;
    _safeNotify();
  }

  void clearSelectedNutritionist() {
    selectedNutritionist = null;
    selectedMode = null;
    _safeNotify();
  }

  void updateMode(NutritionistConsultationMode? mode) {
    selectedMode = mode;
    _safeNotify();
  }

  NutritionistProfileModel? resolveSelectedNutritionist(
    AppointmentController controller,
  ) {
    final selected = selectedNutritionist;
    if (selected == null) return null;

    for (final nutritionist in controller.nutritionists) {
      if (nutritionist.userId == selected.userId) {
        return nutritionist;
      }
    }

    return selected;
  }

  Future<ScheduleAppointmentResult?> scheduleAppointment({
    required AppointmentController controller,
    required NutritionistProfileModel nutritionist,
    required VoidCallback showProcessingDialog,
    required VoidCallback closeProcessingDialog,
    required void Function(ScheduleAppointmentFeedback feedback) onFeedback,
  }) async {
    final latestNutritionist =
        resolveSelectedNutritionist(controller) ?? nutritionist;
    final appointmentNutritionist = latestNutritionist.copyWith(
      consultationMode: selectedMode,
    );
    final price = appointmentNutritionist.consultationPrice ?? 0;

    final validation = _validateBeforePayment(
      controller,
      appointmentNutritionist,
      price,
    );
    if (validation != null) {
      onFeedback(
        ScheduleAppointmentFeedback(message: validation, isError: true),
      );
      return null;
    }

    return _processPaymentAndSchedule(
      controller: controller,
      nutritionist: appointmentNutritionist,
      price: price,
      showProcessingDialog: showProcessingDialog,
      closeProcessingDialog: closeProcessingDialog,
      onFeedback: onFeedback,
    );
  }

  String? _validateBeforePayment(
    AppointmentController controller,
    NutritionistProfileModel nutritionist,
    double price,
  ) {
    if (selectedMode == null) {
      return 'Selecciona una modalidad';
    }
    if (controller.selectedDate == null) {
      return 'Selecciona una fecha para la cita';
    }
    if (controller.selectedHour == null) {
      return 'Selecciona una hora para la cita';
    }
    if (nutritionist.userId.trim().isEmpty) {
      return 'No se encontró el nutricionista seleccionado.';
    }
    if (price <= 0) {
      return 'El nutricionista no tiene un precio válido';
    }

    return null;
  }

  Future<ScheduleAppointmentResult?> _processPaymentAndSchedule({
    required AppointmentController controller,
    required NutritionistProfileModel nutritionist,
    required double price,
    required VoidCallback showProcessingDialog,
    required VoidCallback closeProcessingDialog,
    required void Function(ScheduleAppointmentFeedback feedback) onFeedback,
  }) async {
    try {
      final amountInCents = (price * 100).round();
      if (amountInCents <= 0) {
        onFeedback(
          const ScheduleAppointmentFeedback(
            message: 'El valor de la consulta debe ser mayor a 0.',
            isError: true,
          ),
        );
        return null;
      }

      final paymentIntent = await _paymentService.createPaymentIntent(
        amountInCents: amountInCents,
        nutritionistUserId: nutritionist.userId,
      );

      onFeedback(
        const ScheduleAppointmentFeedback(
          title: 'Pago en línea',
          message:
              'Se abrirá el método de pago. Si no regresa automáticamente, vuelve a la app.',
        ),
      );

      isPaymentFlowActive = true;
      showProcessingDialog();

      try {
        await _paymentService.showPaymentSheet(
          clientSecret: paymentIntent.clientSecret,
        );
      } finally {
        closeProcessingDialog();
        isPaymentFlowActive = false;
      }

      final appointment = await controller
          .scheduleAppointment(
            nutritionist,
            paymentIntentId: paymentIntent.paymentIntentId,
            paidAmount: amountInCents,
            currency: 'usd',
          )
          .timeout(const Duration(seconds: 20), onTimeout: () => null);

      if (appointment != null) {
        return ScheduleAppointmentResult(
          message: 'Pago realizado y cita agendada correctamente',
          appointment: appointment,
        );
      }

      if (controller.errorMessage != null) {
        onFeedback(
          ScheduleAppointmentFeedback(
            message: controller.errorMessage!,
            isError: true,
          ),
        );
      }
      return null;
    } on AppointmentPaymentFailure catch (e) {
      closeProcessingDialog();
      isPaymentFlowActive = false;
      onFeedback(
        ScheduleAppointmentFeedback(message: e.message, isError: true),
      );
      return null;
    } catch (_) {
      closeProcessingDialog();
      isPaymentFlowActive = false;
      onFeedback(
        const ScheduleAppointmentFeedback(
          message: 'No se pudo completar la cita.',
          isError: true,
        ),
      );
      return null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
