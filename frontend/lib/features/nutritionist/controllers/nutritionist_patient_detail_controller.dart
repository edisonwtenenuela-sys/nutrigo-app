import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/features/nutritionist/helpers/nutritionist_patient_status_helper.dart';

class NutritionistPatientClinicalData {
  const NutritionistPatientClinicalData({
    required this.weightText,
    required this.heightText,
    required this.ageText,
    required this.genderText,
    required this.dietaryGoalText,
    required this.allergiesText,
    required this.medicalConditionsText,
  });

  final String weightText;
  final String heightText;
  final String ageText;
  final String genderText;
  final String dietaryGoalText;
  final String allergiesText;
  final String medicalConditionsText;
}

class NutritionistPatientDetailViewData {
  const NutritionistPatientDetailViewData({
    required this.name,
    required this.initial,
    required this.imageUrl,
    required this.status,
    required this.statusColor,
    required this.appointmentCount,
    required this.completedCount,
    required this.confirmedCount,
    required this.lastDateText,
    required this.clinicalData,
  });

  final String name;
  final String initial;
  final String? imageUrl;
  final AppointmentStatus? status;
  final Color statusColor;
  final int appointmentCount;
  final int completedCount;
  final int confirmedCount;
  final String lastDateText;
  final NutritionistPatientClinicalData clinicalData;
}

class NutritionistPatientDetailController {
  const NutritionistPatientDetailController();

  NutritionistPatientDetailViewData buildViewData(
    Map<String, dynamic> patient,
  ) {
    final name = patient['name']?.toString() ?? 'Paciente';
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'P';
    final imageUrl = patient['profileImageUrl']?.toString();
    final lastDate = patient['lastDate'];
    final status = patient['status'] as AppointmentStatus?;
    final statusColor = NutritionistPatientStatusHelper.statusColor(status);
    final appointmentCount = patient['appointmentCount'] as int? ?? 1;
    final completedCount = patient['completedCount'] as int? ?? 0;
    final confirmedCount = patient['confirmedCount'] as int? ?? 0;
    final lastDateText = lastDate != null
        ? DateFormat('EEEE, dd MMMM yyyy', 'es').format(lastDate.toDate())
        : 'Sin fecha registrada';

    return NutritionistPatientDetailViewData(
      name: name,
      initial: initial,
      imageUrl: imageUrl,
      status: status,
      statusColor: statusColor,
      appointmentCount: appointmentCount,
      completedCount: completedCount,
      confirmedCount: confirmedCount,
      lastDateText: lastDateText,
      clinicalData: NutritionistPatientClinicalData(
        weightText: _formatWeight(patient['weight']),
        heightText: _formatHeight(patient['height']),
        ageText: _formatAge(patient['age']),
        genderText: _formatText(patient['gender'], 'No registrado'),
        dietaryGoalText: _formatText(patient['dietaryGoal'], 'No registrado'),
        allergiesText: _formatList(
          patient['allergies'],
          fallback: 'Sin alergias registradas',
        ),
        medicalConditionsText: _formatList(
          patient['medicalConditions'],
          fallback: 'Sin condiciones registradas',
        ),
      ),
    );
  }

  String _formatText(dynamic value, String fallback) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  String _formatAge(dynamic value) {
    final age = _toInt(value);
    if (age == null || age <= 0) return 'No registrada';
    return '$age años';
  }

  String _formatWeight(dynamic value) {
    final weight = _toDouble(value);
    if (weight == null || weight <= 0) return 'No registrado';
    return '${_trimNumber(weight)} kg';
  }

  String _formatHeight(dynamic value) {
    final height = _toDouble(value);
    if (height == null || height <= 0) return 'No registrada';
    if (height < 3) return '${height.toStringAsFixed(2)} m';
    return '${_trimNumber(height)} cm';
  }

  String _formatList(dynamic value, {required String fallback}) {
    final items = _toStringList(
      value,
    ).map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
    if (items.isEmpty) return fallback;
    return items.join(', ');
  }

  List<String> _toStringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) return value.map((item) => item.toString()).toList();
    final text = value.toString().trim();
    if (text.isEmpty) return const [];
    return text
        .split(RegExp(r'[,|]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', '.'));
  }

  String _trimNumber(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }
}








