import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/features/client/controllers/appointment_detail_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AppointmentModel appointment({
    ConsultationMode mode = ConsultationMode.virtual,
    AppointmentStatus status = AppointmentStatus.pending,
    String? meetingLink,
    String? meetingLinkStatus,
    String? address,
    double? latitude,
    double? longitude,
    double amount = 25,
    String currency = 'usd',
  }) {
    return AppointmentModel(
      clientUserId: 'client-1',
      clientName: 'Cliente',
      nutritionistUserId: 'nutritionist-1',
      nutritionistName: 'Nutricionista',
      appointmentDate: Timestamp.fromDate(
        DateTime.now().add(const Duration(minutes: 5)),
      ),
      consultationMode: mode,
      meetingLink: meetingLink,
      meetingLinkStatus: meetingLinkStatus,
      appointmentAddress: address,
      appointmentLatitude: latitude,
      appointmentLongitude: longitude,
      amount: amount,
      currency: currency,
      status: status,
      createdAt: Timestamp.fromDate(DateTime(2026, 1, 1)),
    );
  }

  group('AppointmentDetailController', () {
    test('formatAmount returns amount and uppercase currency', () {
      final controller = AppointmentDetailController(
        appointment: appointment(amount: 18.5, currency: 'usd'),
      );

      expect(controller.formatAmount(), '18.50 USD');
    });

    test('canJoinVirtualAppointment requires confirmed status and link', () {
      final controller = AppointmentDetailController(
        appointment: appointment(
          status: AppointmentStatus.confirmed,
          meetingLink: 'https://meet.example.com/abc',
        ),
      );

      expect(controller.canJoinVirtualAppointment, isTrue);
    });

    test('virtualAccessMessage explains pending meeting link generation', () {
      final controller = AppointmentDetailController(
        appointment: appointment(meetingLinkStatus: 'generating'),
      );

      expect(
        controller.virtualAccessMessage,
        'Estamos generando el enlace de videollamada para esta cita.',
      );
    });

    test('mapsUrl prefers coordinates when location is available', () {
      final controller = AppointmentDetailController(
        appointment: appointment(
          mode: ConsultationMode.presencial,
          address: 'Quito Centro',
          latitude: -0.1807,
          longitude: -78.4678,
        ),
      );

      expect(
        controller.mapsUrl,
        'https://www.google.com/maps/search/?api=1&query=-0.1807,-78.4678',
      );
    });

    test('mapsUrl encodes address when coordinates are missing', () {
      final controller = AppointmentDetailController(
        appointment: appointment(
          mode: ConsultationMode.presencial,
          address: 'Av. Amazonas y Naciones Unidas',
        ),
      );

      expect(
        controller.mapsUrl,
        'https://www.google.com/maps/search/?api=1&query=Av.%20Amazonas%20y%20Naciones%20Unidas',
      );
    });
  });
}
