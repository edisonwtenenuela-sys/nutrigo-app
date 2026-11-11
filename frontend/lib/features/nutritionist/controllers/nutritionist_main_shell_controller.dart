import 'package:flutter/material.dart';

import 'package:emprendedor/core/services/auth/user_session_service.dart';
import 'package:emprendedor/features/nutritionist/controllers/nutritionist_profile_controller.dart';

class NutritionistMainShellController extends ChangeNotifier {
  NutritionistMainShellController({UserSessionService? sessionService})
    : _sessionService = sessionService ?? UserSessionService();

  static const protectedIndexes = {1, 2, 3};
  static const pendingApprovalMessage =
      'Tu perfil está pendiente de aprobación. Esta sección se desbloqueará después.';

  final UserSessionService _sessionService;

  int selectedIndex = 0;
  bool isPreparingShell = true;

  List<String> get titles => const [
    'Inicio',
    'Citas',
    'Pacientes',
    'Validar Productos',
    'Perfil',
  ];

  String get currentTitle => titles[selectedIndex];

  String? get currentUserId => _sessionService.currentUserId();

  Stream<bool> watchVerified(String userId) {
    return _sessionService.watchNutritionistVerified(userId);
  }

  Future<void> prepare(NutritionistProfileController profileController) async {
    // Fuerza una lectura fresca después del registro profesional. Ese
    // formulario usa otro controlador y el provider puede conservar datos
    // incompletos de la sesión anterior.
    await profileController.loadProfile();

    isPreparingShell = false;
    notifyListeners();
  }

  bool selectTab({required int index, required bool isVerified}) {
    if (_isProtectedTab(index) && !isVerified) return false;

    selectedIndex = index;
    notifyListeners();
    return true;
  }

  bool _isProtectedTab(int index) => protectedIndexes.contains(index);
}
