import 'package:emprendedor/data/models/client/appointment_model.dart';

class NutritionistPatientsFilterHelper {
  static List<Map<String, dynamic>> filteredPatients({
    required List<Map<String, dynamic>> patients,
    required String query,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return patients;

    return patients.where((patient) {
      final name = patient['name']?.toString().toLowerCase() ?? '';
      final id = patient['id']?.toString().toLowerCase() ?? '';
      return name.contains(normalizedQuery) || id.contains(normalizedQuery);
    }).toList();
  }

  static int countByStatus(
    List<Map<String, dynamic>> patients,
    AppointmentStatus status,
  ) {
    return patients.where((patient) => patient['status'] == status).length;
  }
}








