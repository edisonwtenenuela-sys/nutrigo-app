import 'package:flutter/material.dart';

import 'package:emprendedor/core/services/auth/user_session_service.dart';
import 'package:emprendedor/features/client/controllers/client_profile_controller.dart';
import 'package:emprendedor/features/client/controllers/client_location_picker_controller.dart';

enum ClientProfileEditUiState { loading, content }

class ClientProfileEditController extends ChangeNotifier {
  ClientProfileEditController({UserSessionService? sessionService})
    : _sessionService = sessionService ?? UserSessionService();

  final UserSessionService _sessionService;

  static const allergyOptions = [
    'Gluten',
    'Lactosa',
    'Frutos secos',
    'Mariscos',
    'Huevo',
    'Soya',
  ];

  static const goals = [
    'Perder peso',
    'Ganar masa muscular',
    'Mejorar salud',
    'Mantener peso',
    'Aumentar energía',
    'Alimentación balanceada',
  ];

  ClientProfileController? _observedController;
  final Map<TextEditingController, VoidCallback> _textListeners = {};
  String? _initialSnapshot;
  bool _disposed = false;

  bool get isPhoneRegister =>
      _sessionService.currentSnapshot()?.isPhoneOnly ?? false;

  bool get hasInitialSnapshot => _initialSnapshot != null;

  ClientProfileEditUiState resolveUiState(ClientProfileController controller) {
    if (controller.profile == null) return ClientProfileEditUiState.loading;
    return ClientProfileEditUiState.content;
  }

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  void observe(ClientProfileController controller) {
    if (_observedController == controller) return;

    removeObservers();
    _observedController = controller;

    for (final textController in _trackedControllers(controller)) {
      void listener() {
        if (_disposed) return;
        controller.clearError();
        notifyListeners();
      }

      _textListeners[textController] = listener;
      textController.addListener(listener);
    }
  }

  void removeObservers() {
    final controller = _observedController;
    if (controller == null) return;

    for (final textController in _trackedControllers(controller)) {
      final listener = _textListeners.remove(textController);
      if (listener != null) {
        textController.removeListener(listener);
      }
    }

    _observedController = null;
  }

  Future<void> ensureProfileLoaded(ClientProfileController controller) async {
    observe(controller);

    if (controller.profile == null) {
      await controller.loadProfile();
    }

    captureInitialSnapshot(controller);
  }

  void captureInitialSnapshot(ClientProfileController controller) {
    _initialSnapshot = profileSnapshot(controller);
    _safeNotify();
  }

  bool hasChanges(ClientProfileController controller) {
    final initialSnapshot = _initialSnapshot;
    if (initialSnapshot == null) return false;

    return profileSnapshot(controller) != initialSnapshot;
  }

  void applyLocation(
    ClientProfileController controller,
    SelectedLocationResult result,
  ) {
    controller.setSelectedLocation(
      address: result.address,
      latitude: result.latitude,
      longitude: result.longitude,
    );
  }

  Future<bool> saveIfChanged(ClientProfileController controller) async {
    if (!hasChanges(controller)) return false;
    final success = await controller.saveProfile();
    if (success) captureInitialSnapshot(controller);
    return success;
  }

  static String? validateEmailValue(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    if (!emailRegex.hasMatch(email)) {
      return 'Ingresa un correo válido';
    }

    return null;
  }

  String? validateEmail(String? value) => validateEmailValue(value);

  String profileSnapshot(ClientProfileController controller) {
    final allergies = [...controller.selectedAllergies]..sort();

    return [
      controller.nameController.text.trim(),
      controller.emailController.text.trim(),
      controller.phoneController.text.trim(),
      controller.addressController.text.trim(),
      controller.goalController.text.trim(),
      controller.ageController.text.trim(),
      controller.weightController.text.trim(),
      controller.heightController.text.trim(),
      controller.selectedGender ?? '',
      controller.latitude?.toString() ?? '',
      controller.longitude?.toString() ?? '',
      allergies.join('|'),
    ].join('|');
  }

  List<TextEditingController> _trackedControllers(
    ClientProfileController controller,
  ) {
    return [
      controller.nameController,
      controller.emailController,
      controller.phoneController,
      controller.addressController,
      controller.goalController,
      controller.ageController,
      controller.weightController,
      controller.heightController,
    ];
  }

  @override
  void dispose() {
    _disposed = true;
    removeObservers();
    super.dispose();
  }
}
