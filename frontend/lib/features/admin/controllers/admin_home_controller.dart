import 'dart:async';

import 'package:flutter/material.dart';

import 'package:emprendedor/data/models/admin/admin_verification_request_model.dart';
import 'package:emprendedor/data/models/admin/nutritionist_verification_request_model.dart';
import 'package:emprendedor/data/repositories/admin/admin_verification_repository.dart';
import 'package:emprendedor/data/repositories/admin/nutritionist_verification_repository.dart';
import 'package:emprendedor/presentation/admin/widgets/index.dart';

class AdminPendingRequestNotice {
  const AdminPendingRequestNotice({required this.title, required this.message});

  final String title;
  final String message;
}

class AdminHomeController extends ChangeNotifier {
  AdminHomeController({
    AdminVerificationRepository? entrepreneurRepository,
    NutritionistVerificationRepository? nutritionistRepository,
  }) : _entrepreneurRepository =
           entrepreneurRepository ?? AdminVerificationRepository(),
       _nutritionistRepository =
           nutritionistRepository ?? NutritionistVerificationRepository();

  final AdminVerificationRepository _entrepreneurRepository;
  final NutritionistVerificationRepository _nutritionistRepository;
  StreamSubscription<List<AdminVerificationRequestModel>>?
  _entrepreneurPendingSubscription;
  StreamSubscription<List<NutritionistVerificationRequestModel>>?
  _nutritionistPendingSubscription;
  Set<String> _knownEntrepreneurPendingIds = <String>{};
  Set<String> _knownNutritionistPendingIds = <String>{};
  bool _hasLoadedEntrepreneurPending = false;
  bool _hasLoadedNutritionistPending = false;

  AdminPanelType selectedPanel = AdminPanelType.pending;

  Stream<List<AdminVerificationRequestModel>> get entrepreneurPendingStream {
    return _entrepreneurRepository.getPendingRequests();
  }

  Stream<List<NutritionistVerificationRequestModel>>
  get nutritionistPendingStream {
    return _nutritionistRepository.getPendingRequests();
  }

  void setPanel(AdminPanelType panel) {
    if (selectedPanel == panel) return;
    selectedPanel = panel;
    notifyListeners();
  }

  void startPendingRequestWatcher({
    required void Function(AdminPendingRequestNotice notice) onNotice,
  }) {
    _entrepreneurPendingSubscription?.cancel();
    _nutritionistPendingSubscription?.cancel();

    _entrepreneurPendingSubscription = entrepreneurPendingStream.listen((
      requests,
    ) {
      final currentIds = requests.map((request) => request.id).toSet();

      if (!_hasLoadedEntrepreneurPending) {
        _knownEntrepreneurPendingIds = currentIds;
        _hasLoadedEntrepreneurPending = true;
        return;
      }

      final newRequests = requests
          .where(
            (request) => !_knownEntrepreneurPendingIds.contains(request.id),
          )
          .toList();

      _knownEntrepreneurPendingIds = currentIds;

      for (final request in newRequests) {
        onNotice(
          AdminPendingRequestNotice(
            title: 'Nueva solicitud de negocio',
            message: '${request.businessName} espera revisión.',
          ),
        );
      }
    });

    _nutritionistPendingSubscription = nutritionistPendingStream.listen((
      requests,
    ) {
      final currentIds = requests.map((request) => request.id).toSet();

      if (!_hasLoadedNutritionistPending) {
        _knownNutritionistPendingIds = currentIds;
        _hasLoadedNutritionistPending = true;
        return;
      }

      final newRequests = requests
          .where(
            (request) => !_knownNutritionistPendingIds.contains(request.id),
          )
          .toList();

      _knownNutritionistPendingIds = currentIds;

      for (final request in newRequests) {
        onNotice(
          AdminPendingRequestNotice(
            title: 'Nueva solicitud profesional',
            message: '${request.name} espera revisión.',
          ),
        );
      }
    });
  }

  Future<void> refresh() async {
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  @override
  void dispose() {
    _entrepreneurPendingSubscription?.cancel();
    _nutritionistPendingSubscription?.cancel();
    super.dispose();
  }
}








