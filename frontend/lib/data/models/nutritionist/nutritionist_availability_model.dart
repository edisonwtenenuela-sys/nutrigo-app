import 'package:cloud_firestore/cloud_firestore.dart';

class NutritionistAvailabilityDay {
  const NutritionistAvailabilityDay({
    required this.enabled,
    required this.startTime,
    required this.endTime,
  });

  final bool enabled;
  final String startTime;
  final String endTime;

  factory NutritionistAvailabilityDay.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const NutritionistAvailabilityDay.disabled();

    return NutritionistAvailabilityDay(
      enabled: map['enabled'] == true,
      startTime: map['startTime']?.toString() ?? '09:00',
      endTime: map['endTime']?.toString() ?? '17:00',
    );
  }

  const NutritionistAvailabilityDay.disabled()
    : enabled = false,
      startTime = '09:00',
      endTime = '17:00';

  Map<String, dynamic> toMap() {
    return {'enabled': enabled, 'startTime': startTime, 'endTime': endTime};
  }

  NutritionistAvailabilityDay copyWith({
    bool? enabled,
    String? startTime,
    String? endTime,
  }) {
    return NutritionistAvailabilityDay(
      enabled: enabled ?? this.enabled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

class NutritionistAvailabilityModel {
  const NutritionistAvailabilityModel({
    required this.nutritionistUserId,
    required this.slotDurationMinutes,
    required this.days,
    this.updatedAt,
  });

  final String nutritionistUserId;
  final int slotDurationMinutes;
  final Map<String, NutritionistAvailabilityDay> days;
  final Timestamp? updatedAt;

  static const weekdayKeys = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  static const weekdayLabels = {
    'monday': 'Lunes',
    'tuesday': 'Martes',
    'wednesday': 'Miércoles',
    'thursday': 'Jueves',
    'friday': 'Viernes',
    'saturday': 'Sábado',
    'sunday': 'Domingo',
  };

  factory NutritionistAvailabilityModel.empty(String nutritionistUserId) {
    return NutritionistAvailabilityModel(
      nutritionistUserId: nutritionistUserId,
      slotDurationMinutes: 60,
      days: {
        for (final key in weekdayKeys)
          key: NutritionistAvailabilityDay(
            enabled: key != 'saturday' && key != 'sunday',
            startTime: '09:00',
            endTime: '17:00',
          ),
      },
    );
  }

  factory NutritionistAvailabilityModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawDays = data['days'] is Map<String, dynamic>
        ? data['days'] as Map<String, dynamic>
        : <String, dynamic>{};

    return NutritionistAvailabilityModel(
      nutritionistUserId:
          data['nutritionistUserId']?.toString().trim().isNotEmpty == true
          ? data['nutritionistUserId'].toString().trim()
          : doc.id,
      slotDurationMinutes: (data['slotDurationMinutes'] as num?)?.toInt() ?? 60,
      days: {
        for (final key in weekdayKeys)
          key: NutritionistAvailabilityDay.fromMap(
            rawDays[key] is Map<String, dynamic>
                ? rawDays[key] as Map<String, dynamic>
                : null,
          ),
      },
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nutritionistUserId': nutritionistUserId,
      'slotDurationMinutes': slotDurationMinutes,
      'days': days.map((key, value) => MapEntry(key, value.toMap())),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  bool get hasConfiguredDays => days.values.any((day) => day.enabled);

  String weekdayKeyFromDate(DateTime date) {
    return weekdayKeys[date.weekday - 1];
  }

  bool isDateEnabled(DateTime date) {
    final day = days[weekdayKeyFromDate(date)];
    return day?.enabled == true;
  }

  List<String> availableSlotsForDate(
    DateTime date, {
    Set<String> bookedHours = const {},
    DateTime? referenceTime,
    int minimumLeadTimeMinutes = 30,
  }) {
    final day = days[weekdayKeyFromDate(date)];
    if (day == null || !day.enabled) return const [];

    final start = _minutesFromTime(day.startTime);
    final end = _minutesFromTime(day.endTime);
    if (start == null || end == null || end <= start) return const [];

    final now = referenceTime ?? DateTime.now();
    final isToday = _isSameDate(date, now);
    final selectedDay = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    if (selectedDay.isBefore(today)) return const [];

    final minimumStart = isToday
        ? (now.hour * 60) + now.minute + minimumLeadTimeMinutes
        : null;

    final slots = <String>[];
    for (
      var minutes = start;
      minutes + slotDurationMinutes <= end;
      minutes += slotDurationMinutes
    ) {
      if (minimumStart != null && minutes < minimumStart) continue;

      final slot = _formatMinutes(minutes);
      if (!bookedHours.contains(slot)) slots.add(slot);
    }

    return slots;
  }

  NutritionistAvailabilityModel copyWith({
    int? slotDurationMinutes,
    Map<String, NutritionistAvailabilityDay>? days,
    Timestamp? updatedAt,
  }) {
    return NutritionistAvailabilityModel(
      nutritionistUserId: nutritionistUserId,
      slotDurationMinutes: slotDurationMinutes ?? this.slotDurationMinutes,
      days: days ?? this.days,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static int? _minutesFromTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return (hour * 60) + minute;
  }

  static String _formatMinutes(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}








