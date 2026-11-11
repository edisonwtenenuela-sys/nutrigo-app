import 'package:flutter/material.dart';

import 'package:emprendedor/core/services/nutritionist/nutritionist_professional_registration_service.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';
import 'package:emprendedor/core/utils/professional_registry_utils.dart';

class NutritionistProfessionalRegistrationResult {
  const NutritionistProfessionalRegistrationResult({required this.message});

  final String message;
}

class NutritionistProfessionalRegistrationController extends ChangeNotifier {
  NutritionistProfessionalRegistrationController({
    NutritionistProfessionalRegistrationService? registrationService,
  }) : _registrationService =
           registrationService ??
           NutritionistProfessionalRegistrationService() {
    nameController.text =
        _registrationService.currentSession()?.displayName ?? '';
  }

  final NutritionistProfessionalRegistrationService _registrationService;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final specialtyController = TextEditingController();
  final licenseController = TextEditingController();
  final descriptionController = TextEditingController();

  String registryType = ProfessionalRegistryUtils.msp;
  String? selectedSpecialty;
  bool isSaving = false;
  bool isLoadingExistingProfile = false;
  bool _hasLoadedExistingProfile = false;
  bool _disposed = false;

  String get currentEmail => _registrationService.currentSession()?.email ?? '';
  bool get isCustomSpecialty => selectedSpecialty == 'Otra';

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  void updateSpecialty(String? value) {
    selectedSpecialty = value;
    if (value == 'Otra') {
      specialtyController.clear();
    } else {
      specialtyController.text = value ?? '';
    }
    _safeNotify();
  }

  void updateRegistryType(String? value) {
    if (value == null) return;
    final normalized = ProfessionalRegistryUtils.normalizeRegistryType(value);
    if (registryType == normalized) return;
    registryType = normalized;
    licenseController.clear();
    _safeNotify();
  }

  Future<void> loadExistingProfile() async {
    if (_hasLoadedExistingProfile || isLoadingExistingProfile) return;
    _hasLoadedExistingProfile = true;
    isLoadingExistingProfile = true;
    _safeNotify();

    try {
      final profile = await _registrationService.loadExistingProfile();
      if (profile == null) return;

      _applyExistingProfile(profile);
    } finally {
      isLoadingExistingProfile = false;
      _safeNotify();
    }
  }

  void _applyExistingProfile(NutritionistProfileModel profile) {
    _fillIfPresent(nameController, profile.name);
    _fillIfPresent(phoneController, _localPhone(profile.phone));
    _fillIfPresent(licenseController, profile.licenseNumber);
    _fillIfPresent(descriptionController, profile.professionalDescription);

    registryType = ProfessionalRegistryUtils.normalizeRegistryType(
      profile.professionalRegistryType,
    );

    final savedSpecialty = profile.specialty?.trim();
    if (savedSpecialty == null || savedSpecialty.isEmpty) return;

    if (ProfessionalRegistryUtils.specialtyOptions.contains(savedSpecialty)) {
      selectedSpecialty = savedSpecialty;
      specialtyController.text = savedSpecialty;
      return;
    }

    selectedSpecialty = 'Otra';
    specialtyController.text = savedSpecialty;
  }

  void _fillIfPresent(TextEditingController controller, String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return;
    controller.text = text;
  }

  String? _localPhone(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return null;

    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('593')) {
      return '0${digits.substring(3)}';
    }
    if (digits.length > 10) return digits.substring(digits.length - 10);
    return digits;
  }

  Future<NutritionistProfessionalRegistrationResult?> submit() async {
    if (isSaving) return null;
    if (!(formKey.currentState?.validate() ?? false)) return null;

    final session = _registrationService.currentSession();
    if (session == null) {
      throw const NutritionistProfessionalRegistrationFailure(
        'No hay usuario autenticado.',
      );
    }

    isSaving = true;
    _safeNotify();

    try {
      await _registrationService
          .submitRegistration(
            session: session,
            name: nameController.text.trim(),
            phone: phoneController.text.trim(),
            specialty: specialtyController.text.trim(),
            licenseNumber: licenseController.text.trim(),
            professionalRegistryType: registryType,
            professionalDescription: descriptionController.text.trim(),
          )
          .timeout(const Duration(seconds: 20));

      return const NutritionistProfessionalRegistrationResult(
        message: 'Solicitud de verificación enviada.',
      );
    } catch (_) {
      throw const NutritionistProfessionalRegistrationFailure(
        'No se pudo enviar la solicitud. Revisa tu conexión e inténtalo nuevamente.',
      );
    } finally {
      isSaving = false;
      _safeNotify();
    }
  }

  static String? requiredFieldValue(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Campo obligatorio';
    return null;
  }

  static String? validatePhoneValue(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) return 'Campo obligatorio';
    if (digits.length != 10) return 'Ingresa 10 dígitos para el celular';

    return null;
  }

  static String? validateDescriptionValue(String? value) {
    final text = (value ?? '').trim();

    if (text.isEmpty) return 'Campo obligatorio';
    if (text.length < 20) return 'Describe un poco más tu experiencia';

    return null;
  }

  String? requiredField(String? value) => requiredFieldValue(value);

  String? validatePhone(String? value) => validatePhoneValue(value);

  String? validateSpecialty(String? value) {
    if (selectedSpecialty == null) return 'Selecciona tu especialidad';

    if (selectedSpecialty == 'Otra' &&
        specialtyController.text.trim().isEmpty) {
      return 'Ingresa tu especialidad';
    }

    return null;
  }

  String? validateLicense(String? value) {
    return ProfessionalRegistryUtils.validateProfessionalLicense(
      registryType: registryType,
      value: value,
    );
  }

  String? validateDescription(String? value) => validateDescriptionValue(value);

  @override
  void dispose() {
    _disposed = true;
    nameController.dispose();
    phoneController.dispose();
    specialtyController.dispose();
    licenseController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}

class NutritionistProfessionalRegistrationFailure implements Exception {
  const NutritionistProfessionalRegistrationFailure(this.message);

  final String message;
}
