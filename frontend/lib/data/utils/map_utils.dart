import 'package:cloud_firestore/cloud_firestore.dart';

/// Helpers para leer valores tipados de mapas de Firestore.
/// Centraliza los patrones repetidos en fromMap() de todos los modelos.

/// Convierte un campo Timestamp de Firestore a DateTime. Retorna null si ausente.
DateTime? dateFromMap(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is Timestamp) return value.toDate();
  return null;
}

/// Convierte un campo Timestamp a DateTime. Usa [fallback] si el campo es null.
DateTime dateFromMapOrNow(Map<String, dynamic> map, String key) {
  return dateFromMap(map, key) ?? DateTime.now();
}

/// Lee un campo numérico como double. Retorna null si ausente.
double? doubleFromMap(Map<String, dynamic> map, String key) {
  return (map[key] as num?)?.toDouble();
}

/// Lee un campo numérico como int. Retorna [defaultValue] si ausente.
int intFromMap(Map<String, dynamic> map, String key, {int defaultValue = 0}) {
  return (map[key] as num?)?.toInt() ?? defaultValue;
}

/// Lee un campo String. Retorna null si ausente.
String? stringFromMap(Map<String, dynamic> map, String key) {
  return map[key]?.toString();
}

/// Lee un campo String. Retorna [fallback] si ausente.
String stringFromMapOr(
  Map<String, dynamic> map,
  String key, {
  String fallback = '',
}) {
  return map[key]?.toString() ?? fallback;
}

/// Lee un campo bool. Retorna [defaultValue] si ausente.
bool boolFromMap(
  Map<String, dynamic> map,
  String key, {
  bool defaultValue = false,
}) {
  return map[key] as bool? ?? defaultValue;
}

/// Lee una lista de strings. Retorna lista vacía si ausente.
List<String> stringListFromMap(Map<String, dynamic> map, String key) {
  return List<String>.from(map[key] ?? []);
}








