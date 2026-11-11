import 'package:flutter/material.dart';

import 'package:emprendedor/core/services/auth/user_session_service.dart';
import 'package:emprendedor/data/models/client/client_profile_model.dart';
import 'package:emprendedor/features/client/controllers/client_profile_controller.dart';

enum ClientProfileUiState { loading, content }

class ClientProfileViewController extends ChangeNotifier {
  ClientProfileViewController({UserSessionService? sessionService})
    : _sessionService = sessionService ?? UserSessionService();

  final UserSessionService _sessionService;

  bool _initialized = false;

  UserSessionSnapshot? get currentSession => _sessionService.currentSnapshot();

  ClientProfileUiState resolveUiState(ClientProfileController controller) {
    if (controller.profile == null) return ClientProfileUiState.loading;
    return ClientProfileUiState.content;
  }

  void ensureProfileLoaded(ClientProfileController controller) {
    if (_initialized) return;
    _initialized = true;

    if (controller.profile == null) {
      controller.loadProfile();
    }
  }

  EditProfileSnapshot captureEditSnapshot(ClientProfileController controller) {
    return EditProfileSnapshot(
      email: controller.emailController.text,
      profile: controller.profile,
    );
  }

  void restoreAfterCancelledEdit({
    required ClientProfileController controller,
    required EditProfileSnapshot snapshot,
  }) {
    controller.loadInitialData(snapshot.profile);
    controller.emailController.text = snapshot.email;
    notifyListeners();
  }

  bool shouldShowEmailVerificationCard({
    required UserSessionSnapshot? session,
    required ClientProfileController controller,
  }) {
    final isPhoneRegister = session?.isPhoneOnly ?? false;
    return !isPhoneRegister && !isClientEmailVerified(session, controller);
  }

  bool isClientEmailVerified(
    UserSessionSnapshot? session,
    ClientProfileController controller,
  ) {
    final providerIds = session?.providerIds ?? <String>{};

    if (providerIds.contains('phone') || providerIds.contains('google.com')) {
      return true;
    }

    if (providerIds.contains('password')) {
      return session?.emailVerified ?? false;
    }

    return session?.emailVerified ?? controller.isVerified;
  }

  bool resolveHeaderVerified(
    ClientProfileController controller,
    UserSessionSnapshot? session,
  ) {
    final providerIds = session?.providerIds ?? <String>{};

    final isPhoneAuth = providerIds.contains('phone');
    final isGoogleAuth = providerIds.contains('google.com');
    final isPasswordAuth = providerIds.contains('password');

    if (isPhoneAuth || isGoogleAuth) return true;
    if (isPasswordAuth) return session?.emailVerified ?? false;

    return controller.isVerified;
  }

  bool hasHealthData(ClientProfileController controller) {
    return controller.weightController.text.trim().isNotEmpty ||
        controller.heightController.text.trim().isNotEmpty ||
        controller.selectedAllergies.isNotEmpty;
  }

  void refreshView() {
    notifyListeners();
  }
}

class EditProfileSnapshot {
  const EditProfileSnapshot({required this.email, required this.profile});

  final String email;
  final ClientProfileModel? profile;
}








