import 'package:emprendedor/data/models/nutritionist/nutritionist_availability_model.dart';
import 'package:emprendedor/features/client/controllers/schedule_appointment_controller.dart';
import 'package:emprendedor/features/client/helpers/appointment_date_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppointmentDateHelper', () {
    test('nextBusinessDay skips weekends', () {
      final friday = DateTime(2026, 6, 12);

      expect(
        AppointmentDateHelper.nextBusinessDay(friday),
        DateTime(2026, 6, 15),
      );
    });

    test('isWeekday allows Monday to Friday only', () {
      expect(AppointmentDateHelper.isWeekday(DateTime(2026, 6, 9)), isTrue);
      expect(AppointmentDateHelper.isWeekday(DateTime(2026, 6, 13)), isFalse);
      expect(AppointmentDateHelper.isWeekday(DateTime(2026, 6, 14)), isFalse);
    });

    test('maxSchedulingDate keeps same month and day two years later', () {
      expect(
        AppointmentDateHelper.maxSchedulingDate(DateTime(2026, 6, 9)),
        DateTime(2028, 6, 9),
      );
    });
  });

  group('ScheduleAppointmentController date helpers', () {
    test('initialSchedulingDate returns the next calendar day', () {
      expect(
        ScheduleAppointmentController.initialSchedulingDate(
          DateTime(2026, 6, 12),
        ),
        DateTime(2026, 6, 13),
      );
    });

    test(
      'canSelectDate allows future dates because availability controls days',
      () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        expect(ScheduleAppointmentController.canSelectDate(tomorrow), isTrue);
      },
    );
  });

  group('NutritionistAvailabilityModel slots', () {
    final availability = NutritionistAvailabilityModel(
      nutritionistUserId: 'nutritionist-1',
      slotDurationMinutes: 60,
      days: {
        for (final key in NutritionistAvailabilityModel.weekdayKeys)
          key: key == 'thursday'
              ? const NutritionistAvailabilityDay(
                  enabled: true,
                  startTime: '09:00',
                  endTime: '17:00',
                )
              : const NutritionistAvailabilityDay.disabled(),
      },
    );

    test('filters past slots and applies lead time for today', () {
      final slots = availability.availableSlotsForDate(
        DateTime(2026, 6, 18),
        referenceTime: DateTime(2026, 6, 18, 12, 12),
      );

      expect(slots, ['13:00', '14:00', '15:00', '16:00']);
    });

    test('keeps configured slots for future dates', () {
      final slots = availability.availableSlotsForDate(
        DateTime(2026, 6, 18),
        referenceTime: DateTime(2026, 6, 17, 12, 12),
      );

      expect(slots, [
        '09:00',
        '10:00',
        '11:00',
        '12:00',
        '13:00',
        '14:00',
        '15:00',
        '16:00',
      ]);
    });
  });
}
