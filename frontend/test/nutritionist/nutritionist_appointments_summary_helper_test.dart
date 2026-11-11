import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/features/nutritionist/helpers/nutritionist_appointments_summary_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AppointmentModel appointment(AppointmentStatus status) {
    return AppointmentModel(
      clientUserId: 'client-1',
      clientName: 'Cliente',
      nutritionistUserId: 'nutritionist-1',
      nutritionistName: 'Nutricionista',
      appointmentDate: Timestamp.fromDate(DateTime(2026, 1, 1)),
      amount: 20,
      status: status,
      createdAt: Timestamp.fromDate(DateTime(2026, 1, 1)),
    );
  }

  group('NutritionistAppointmentsSummaryHelper', () {
    test('countByStatus counts appointments by status', () {
      final appointments = [
        appointment(AppointmentStatus.pending),
        appointment(AppointmentStatus.pending),
        appointment(AppointmentStatus.completed),
        appointment(AppointmentStatus.cancelled),
      ];

      expect(
        NutritionistAppointmentsSummaryHelper.countByStatus(
          appointments,
          AppointmentStatus.pending,
        ),
        2,
      );
      expect(
        NutritionistAppointmentsSummaryHelper.countByStatus(
          appointments,
          AppointmentStatus.completed,
        ),
        1,
      );
      expect(
        NutritionistAppointmentsSummaryHelper.countByStatus(
          appointments,
          AppointmentStatus.confirmed,
        ),
        0,
      );
    });
  });
}
