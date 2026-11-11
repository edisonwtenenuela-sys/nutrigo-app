import 'package:cloud_firestore/cloud_firestore.dart';

class EcuadorTimeUtils {
  const EcuadorTimeUtils._();

  static const Duration utcOffset = Duration(hours: -5);

  static DateTime fromEcuadorLocalParts({
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
  }) {
    return DateTime.utc(year, month, day, hour, minute).subtract(utcOffset);
  }

  static DateTime timestampToEcuadorDateTime(Timestamp timestamp) {
    return timestamp.toDate().toUtc().add(utcOffset);
  }

  static String hourLabelFromTimestamp(Timestamp timestamp) {
    final date = timestampToEcuadorDateTime(timestamp);
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  static String slotDateKeyFromTimestamp(Timestamp timestamp) {
    final date = timestampToEcuadorDateTime(timestamp);
    return '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
