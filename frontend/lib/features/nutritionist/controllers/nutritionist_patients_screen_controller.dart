import 'package:flutter/material.dart';

import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/features/nutritionist/controllers/nutritionist_patients_controller.dart';
import 'package:emprendedor/features/nutritionist/helpers/nutritionist_patients_filter_helper.dart';

typedef NutritionistPatientsOverview = ({int total, int active, int completed});

class NutritionistPatientsScreenController extends ChangeNotifier {
  final searchController = TextEditingController();
  String query = '';

  void setQuery(String value) {
    if (query == value) return;
    query = value;
    notifyListeners();
  }

  Future<void> load(NutritionistPatientsController controller) {
    return controller.loadPatients();
  }

  List<Map<String, dynamic>> filteredPatients(
    List<Map<String, dynamic>> patients,
  ) {
    return NutritionistPatientsFilterHelper.filteredPatients(
      patients: patients,
      query: query,
    );
  }

  NutritionistPatientsOverview buildOverview(
    List<Map<String, dynamic>> patients,
  ) {
    return (
      total: patients.length,
      active: NutritionistPatientsFilterHelper.countByStatus(
        patients,
        AppointmentStatus.confirmed,
      ),
      completed: NutritionistPatientsFilterHelper.countByStatus(
        patients,
        AppointmentStatus.completed,
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}








