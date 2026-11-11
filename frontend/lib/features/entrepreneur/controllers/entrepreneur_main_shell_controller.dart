import 'package:flutter/material.dart';

import 'package:emprendedor/core/services/auth/user_session_service.dart';
import 'package:emprendedor/features/entrepreneur/controllers/payment_method_controller.dart';
import 'package:emprendedor/features/entrepreneur/controllers/profile_controller.dart';
import 'package:emprendedor/features/entrepreneur/controllers/social_media_controller.dart';

class EntrepreneurMainShellController extends ChangeNotifier {
  EntrepreneurMainShellController({UserSessionService? sessionService})
    : _sessionService = sessionService ?? UserSessionService();

  static const protectedIndexes = {1, 2, 3, 4, 5};
  static const pendingApprovalMessage =
      'Tu negocio está pendiente de aprobación. Esta sección se desbloqueará después.';

  final UserSessionService _sessionService;

  int selectedIndex = 0;
  bool isPreparingShell = true;
  bool isLoggingOut = false;

  List<String> get pageTitles => const [
    'Inicio',
    'Mis Productos',
    'Mis Pedidos',
    'Estadisticas',
    'Promociones',
    'Perfil',
  ];

  String get currentTitle => pageTitles[selectedIndex];

  String? get currentUserId => _sessionService.currentUserId();

  Future<void> prepare(ProfileController profileController) async {
    final userId = currentUserId;
    if (userId != null) {
      if (profileController.userId == userId) {
        // El formulario inicial usa un controlador independiente. Al volver
        // desde AuthWrapper, el provider puede conservar el borrador anterior
        // aunque el perfil completo ya esté guardado en Firestore.
        await profileController.fetchBusinessProfile();
      } else {
        await profileController.setUserId(userId);
      }
    }

    isPreparingShell = false;
    notifyListeners();
  }

  Future<bool> selectTab(int index) async {
    if (selectedIndex == index) return true;

    if (protectedIndexes.contains(index)) {
      final isVerified = await _isEntrepreneurVerified();
      if (!isVerified) return false;
    }

    selectedIndex = index;
    notifyListeners();
    return true;
  }

  bool startLogout() {
    if (isLoggingOut) return false;

    isLoggingOut = true;
    return true;
  }

  Future<String?> prepareEditProfile(ProfileController controller) async {
    final userId = currentUserId;
    if (userId == null) return null;

    await controller.setUserId(userId);
    return userId;
  }

  Future<bool> preparePaymentMethods(PaymentMethodController controller) async {
    final userId = currentUserId;
    if (userId == null) return false;

    await controller.setUserId(userId);
    return true;
  }

  Future<bool> prepareSocialMedia(SocialMediaController controller) async {
    final userId = currentUserId;
    if (userId == null) return false;

    await controller.setUserId(userId);
    return true;
  }

  Future<bool> _isEntrepreneurVerified() async {
    final userId = currentUserId;
    if (userId == null) return false;
    return _sessionService.isEntrepreneurVerified(userId);
  }
}
