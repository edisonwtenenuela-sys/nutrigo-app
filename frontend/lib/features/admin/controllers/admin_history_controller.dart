import 'package:flutter/material.dart';
import 'package:emprendedor/core/services/admin/admin_diagnostics_service.dart';
import 'package:emprendedor/data/models/admin/admin_verification_request_model.dart';
import 'package:emprendedor/data/models/admin/nutritionist_verification_request_model.dart';
import 'package:emprendedor/data/repositories/admin/admin_verification_repository.dart';
import 'package:emprendedor/data/repositories/admin/nutritionist_verification_repository.dart';

enum AdminHistoryStatus { approved, rejected }

enum AdminHistoryType { entrepreneurs, nutritionists }

class AdminVerificationHistoryController extends ChangeNotifier {
  AdminVerificationHistoryController({
    required this.initialStatus,
    AdminVerificationRepository? entrepreneurRepository,
    NutritionistVerificationRepository? nutritionistRepository,
  }) : _entrepreneurRepository =
           entrepreneurRepository ?? AdminVerificationRepository(),
       _nutritionistRepository =
           nutritionistRepository ?? NutritionistVerificationRepository();

  final AdminHistoryStatus initialStatus;
  final AdminVerificationRepository _entrepreneurRepository;
  final NutritionistVerificationRepository _nutritionistRepository;

  AdminHistoryType type = AdminHistoryType.entrepreneurs;

  String get statusValue {
    return initialStatus == AdminHistoryStatus.approved
        ? 'approved'
        : 'rejected';
  }

  String get title {
    return initialStatus == AdminHistoryStatus.approved
        ? 'Solicitudes aprobadas'
        : 'Solicitudes rechazadas';
  }

  bool get isApproved => initialStatus == AdminHistoryStatus.approved;

  Stream<List<AdminVerificationRequestModel>> get entrepreneurStream {
    return _entrepreneurRepository.getRequestsByStatus(statusValue);
  }

  Stream<List<NutritionistVerificationRequestModel>> get nutritionistStream {
    return _nutritionistRepository.getRequestsByStatus(statusValue);
  }

  void changeType(AdminHistoryType value) {
    if (type == value) return;
    type = value;
    notifyListeners();
  }
}

class NutritionistVerificationScreenController extends ChangeNotifier {
  NutritionistVerificationScreenController({
    AdminDiagnosticsService? diagnosticsService,
  }) : _diagnosticsService = diagnosticsService ?? AdminDiagnosticsService();

  final AdminDiagnosticsService _diagnosticsService;

  Map<String, String> diagnostics = const {};

  Future<void> loadDiagnostics() async {
    try {
      diagnostics = await _diagnosticsService.loadDiagnostics();
    } catch (e) {
      diagnostics = {'error': e.toString()};
    }
    notifyListeners();
  }
}








