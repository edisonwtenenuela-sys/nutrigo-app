class AppointmentDateHelper {
  const AppointmentDateHelper._();

  static DateTime nextBusinessDay(DateTime date) {
    var next = date.add(const Duration(days: 1));

    while (!isWeekday(next)) {
      next = next.add(const Duration(days: 1));
    }

    return next;
  }

  static bool isWeekday(DateTime date) {
    return date.weekday >= DateTime.monday && date.weekday <= DateTime.friday;
  }

  static DateTime maxSchedulingDate(DateTime date) {
    return DateTime(date.year + 2, date.month, date.day);
  }
}








