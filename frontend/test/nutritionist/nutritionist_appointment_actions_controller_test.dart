import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/features/nutritionist/controllers/nutritionist_appointment_actions_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AppointmentModel appointment({
    ConsultationMode mode = ConsultationMode.virtual,
    String? meetingLink,
    String? address,
    String? phone,
  }) {
    return AppointmentModel(
      clientUserId: 'client-1',
      clientName: 'Cliente',
      nutritionistUserId: 'nutritionist-1',
      nutritionistName: 'Nutricionista',
      appointmentDate: Timestamp.fromDate(DateTime(2026, 1, 1)),
      consultationMode: mode,
      meetingLink: meetingLink,
      clientContactPhone: phone,
      appointmentAddress: address,
      amount: 20,
      createdAt: Timestamp.fromDate(DateTime(2026, 1, 1)),
    );
  }

  group('NutritionistAppointmentActionsController', () {
    test('exposes meeting action only for virtual appointments with link', () {
      final controller = NutritionistAppointmentActionsController(
        appointment: appointment(meetingLink: 'https://meet.example.com/abc'),
      );

      expect(controller.canOpenMeetingLink, isTrue);
      expect(controller.meetingUrl, 'https://meet.example.com/abc');
    });

    test('builds maps URL from presencial address', () {
      final controller = NutritionistAppointmentActionsController(
        appointment: appointment(
          mode: ConsultationMode.presencial,
          address: 'Av. Amazonas y Naciones Unidas',
        ),
      );

      expect(controller.canOpenMaps, isTrue);
      expect(
        controller.mapsUrl,
        'https://www.google.com/maps/search/?api=1&query=Av.%20Amazonas%20y%20Naciones%20Unidas',
      );
    });

    test('builds WhatsApp URL with digits only', () {
      final controller = NutritionistAppointmentActionsController(
        appointment: appointment(phone: '+593 99 999 9999'),
      );

      expect(controller.canOpenWhatsApp, isTrue);
      expect(controller.whatsappUrl, 'https://wa.me/593999999999');
    });
  });
}
