import 'package:emprendedor/features/entrepreneur/controllers/statistics_screen_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatisticsScreenController date helpers', () {
    test('defaultDateRange returns the last 30 days from reference date', () {
      final now = DateTime(2026, 6, 9, 10, 30);
      final range = StatisticsScreenController.defaultDateRange(now: now);

      expect(range.start, DateTime(2026, 5, 10, 10, 30));
      expect(range.end, now);
    });

    test('selectable dates keep fixed first date and one-day future limit', () {
      final now = DateTime(2026, 6, 9, 10, 30);

      expect(StatisticsScreenController.firstSelectableDate(), DateTime(2020));
      expect(
        StatisticsScreenController.lastSelectableDate(now: now),
        DateTime(2026, 6, 10, 10, 30),
      );
    });
  });
}
