import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:emprendedor/core/utils/professional_registry_utils.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';
import 'package:emprendedor/data/repositories/nutritionist/nutritionist_profile_repository.dart';
import 'package:emprendedor/core/services/auth/user_session_service.dart';

class NutritionistProfileSaveResult {
  const NutritionistProfileSaveResult({
    required this.success,
    required this.message,
    required this.requiresAuthRedirect,
  });

  final bool success;
  final String message;
  final bool requiresAuthRedirect;

  static NutritionistProfileSaveResult fromControllerState({
    required bool success,
    String? errorMessage,
  }) {
    if (success) {
      return const NutritionistProfileSaveResult(
        success: true,
        message: 'Tu información profesional se actualizó correctamente.',
        requiresAuthRedirect: false,
      );
    }

    final message = errorMessage ?? 'Error al guardar el perfil';

    return NutritionistProfileSaveResult(
      success: false,
      message: message,
      requiresAuthRedirect: _isAuthExpiredError(message),
    );
  }

  static bool _isAuthExpiredError(String message) {
    return message.toLowerCase().contains('no hay usuario autenticado');
  }
}

class NutritionistProfileController extends ChangeNotifier {
  final Logger _logger = Logger('NutritionistProfileController');
  final NutritionistProfileRepository _repository =
      NutritionistProfileRepository();
  final UserSessionService _sessionService = UserSessionService();
  final ImagePicker _imagePicker = ImagePicker();

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final specialtyController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final meetingLinkController = TextEditingController();
  final consultationAddressController = TextEditingController();
  final consultationInstructionsController = TextEditingController();

  late final List<TextEditingController> _allControllers = [
    nameController,
    phoneController,
    specialtyController,
    descriptionController,
    priceController,
    licenseNumberController,
    meetingLinkController,
    consultationAddressController,
    consultationInstructionsController,
  ];

  double? _consultationLatitude;
  double? get consultationLatitude => _consultationLatitude;

  double? _consultationLongitude;
  double? get consultationLongitude => _consultationLongitude;

  bool get hasSelectedLocation =>
      _consultationLatitude != null && _consultationLongitude != null;

  NutritionistProfileModel? _currentProfile;
  NutritionistProfileModel? get currentProfile => _currentProfile;

  NutritionistConsultationMode _selectedMode =
      NutritionistConsultationMode.virtual;
  NutritionistConsultationMode get selectedMode => _selectedMode;

  String _professionalRegistryType = ProfessionalRegistryUtils.msp;
  String get professionalRegistryType => _professionalRegistryType;

  bool _isLoadingProfile = false;
  bool get isLoadingProfile => _isLoadingProfile;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool _isUploadingImage = false;
  bool get isUploadingImage => _isUploadingImage;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _loadErrorMessage;
  String? get loadErrorMessage => _loadErrorMessage;

  StreamSubscription<NutritionistProfileModel?>? _profileSubscription;

  bool get isVerified => _currentProfile?.isVerified ?? false;

  bool get isRejected =>
      _currentProfile?.verificationStatus?.toLowerCase() == 'rejected';

  bool get isProfessionalRegistryLocked {
    final profile = _currentProfile;
    if (profile == null) return false;

    final hasRegistry =
        (profile.licenseNumber?.trim().isNotEmpty ?? false) ||
        (profile.professionalRegistryType?.trim().isNotEmpty ?? false);
    if (!hasRegistry) return false;

    final status = profile.verificationStatus?.trim().toLowerCase() ?? '';
    if (status == 'rejected' || status == 'not_submitted') return false;

    return profile.isVerified ||
        status == 'pending' ||
        status == 'approved' ||
        profile.role == 'pending_nutritionist';
  }

  Future<void> loadProfile() async {
    final session = _sessionService.currentSnapshot();

    if (session == null) {
      _setLoadError('No hay usuario autenticado.');
      return;
    }

    // Cancela suscripción anterior si existe
    await _profileSubscription?.cancel();
    _profileSubscription = null;

    _setLoadingProfile(true);
    _setError(null);
    _setLoadError(null);

    final firstSnapshot = Completer<void>();

    _profileSubscription = _repository
        .watchNutritionistProfile(session.uid)
        .listen(
          (profile) {
            loadInitialData(profile);
            _setLoadingProfile(false);
            if (!firstSnapshot.isCompleted) firstSnapshot.complete();
          },
          onError: (e, stackTrace) {
            _logger.severe(
              'Error escuchando perfil de nutricionista',
              e,
              stackTrace,
            );
            _setError('No se pudo cargar el perfil.');
            _setLoadError('No se pudo cargar el perfil.');
            _setLoadingProfile(false);
            if (!firstSnapshot.isCompleted) firstSnapshot.complete();
          },
        );

    // No damos por terminada la preparación hasta tener el primer perfil real.
    // Así Inicio nunca se pinta antes con "Profesional" y campos vacíos.
    await firstSnapshot.future;
  }

  void loadInitialData(NutritionistProfileModel? profile) {
    _currentProfile = profile;
    _loadErrorMessage = null;

    _fillController(nameController, profile?.name);
    _fillController(phoneController, _localEcuadorPhone(profile?.phone));
    _fillController(specialtyController, profile?.specialty);
    _fillController(descriptionController, profile?.professionalDescription);
    _fillController(licenseNumberController, profile?.licenseNumber);
    _fillController(meetingLinkController, profile?.meetingLink);
    _fillController(
      consultationAddressController,
      profile?.consultationAddress,
    );
    _fillController(
      consultationInstructionsController,
      profile?.consultationInstructions,
    );

    _consultationLatitude = profile?.consultationLatitude;
    _consultationLongitude = profile?.consultationLongitude;
    _selectedMode =
        profile?.consultationMode ?? NutritionistConsultationMode.virtual;
    _professionalRegistryType = ProfessionalRegistryUtils.normalizeRegistryType(
      profile?.professionalRegistryType,
    );
    priceController.text = profile?.consultationPrice?.toStringAsFixed(2) ?? '';

    notifyListeners();
  }

  void setSpecialty(String value) {
    if (isProfessionalRegistryLocked) return;

    specialtyController.text = value;
    clearError();
    notifyListeners();
  }

  void setProfessionalRegistryType(String value) {
    if (isProfessionalRegistryLocked) return;

    final normalized = ProfessionalRegistryUtils.normalizeRegistryType(value);
    if (_professionalRegistryType == normalized) return;

    _professionalRegistryType = normalized;
    licenseNumberController.clear();
    clearError();
    notifyListeners();
  }

  void setConsultationMode(NutritionistConsultationMode mode) {
    if (_selectedMode == mode) return;

    _selectedMode = mode;
    notifyListeners();
  }

  void setConsultationLocation({
    required double latitude,
    required double longitude,
    String? address,
  }) {
    _consultationLatitude = latitude;
    _consultationLongitude = longitude;

    final cleanAddress = address?.trim();

    if (cleanAddress != null && cleanAddress.isNotEmpty) {
      consultationAddressController.value = TextEditingValue(
        text: cleanAddress,
        selection: TextSelection.collapsed(offset: cleanAddress.length),
      );
    }

    clearError();
    notifyListeners();
  }

  void clearConsultationLocation() {
    _consultationLatitude = null;
    _consultationLongitude = null;
    consultationAddressController.clear();

    notifyListeners();
  }

  Future<bool> pickAndUploadProfileImage() async {
    final session = _sessionService.currentSnapshot();

    if (session == null) {
      _setError('No hay usuario autenticado.');
      return false;
    }

    try {
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 900,
      );

      if (pickedImage == null) return false;

      _setError(null);
      _setUploadingImage(true);

      final imageUrl = await _repository
          .uploadProfileImage(
            userId: session.uid,
            imageFile: File(pickedImage.path),
          )
          .timeout(const Duration(seconds: 25));

      await _sessionService
          .updateCurrentPhotoUrl(imageUrl)
          .timeout(const Duration(seconds: 10));

      final existingProfile =
          _currentProfile ??
          await _repository
              .getNutritionistProfile(session.uid)
              .timeout(const Duration(seconds: 12));

      if (existingProfile != null) {
        _currentProfile = existingProfile.copyWith(profileImageUrl: imageUrl);
        notifyListeners();
      }

      return true;
    } catch (e, stackTrace) {
      _logger.severe('Error subiendo imagen', e, stackTrace);
      _setError('No se pudo subir la foto. ${friendlyErrorMessage(e)}');
      return false;
    } finally {
      _setUploadingImage(false);
    }
  }

  Future<NutritionistProfileSaveResult> saveProfileResult() async {
    final success = await saveProfile();
    return NutritionistProfileSaveResult.fromControllerState(
      success: success,
      errorMessage: _errorMessage,
    );
  }

  Future<bool> saveProfile() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;

    final session = _sessionService.currentSnapshot();

    if (session == null) {
      _setError('No hay usuario autenticado.');
      return false;
    }

    final trimmedPrice = priceController.text.trim();
    final price = _parseOptionalPrice(trimmedPrice);

    if (trimmedPrice.isNotEmpty && price == null) {
      _setError('Precio inválido.');
      return false;
    }

    _setError(null);
    _setSaving(true);

    try {
      final existingProfile =
          _currentProfile ??
          await _repository
              .getNutritionistProfile(session.uid)
              .timeout(const Duration(seconds: 12));

      final profile = NutritionistProfileModel(
        id: existingProfile?.id ?? session.uid,
        userId: session.uid,
        name: nameController.text.trim(),
        role: existingProfile?.role ?? 'pending_nutritionist',
        email: existingProfile?.email,
        phone: phoneController.text.trim(),
        profileImageUrl: existingProfile?.profileImageUrl,
        specialty: isProfessionalRegistryLocked
            ? existingProfile?.specialty
            : specialtyController.text.trim(),
        professionalDescription: descriptionController.text.trim(),
        licenseNumber: isProfessionalRegistryLocked
            ? existingProfile?.licenseNumber
            : licenseNumberController.text.trim(),
        professionalRegistryType: isProfessionalRegistryLocked
            ? existingProfile?.professionalRegistryType
            : _professionalRegistryType,
        consultationMode: _selectedMode,
        consultationPrice: price,
        availableDays: existingProfile?.availableDays ?? const [],
        attentionHours: existingProfile?.attentionHours,
        meetingLink: _nullableTrim(meetingLinkController.text),
        consultationAddress: _nullableTrim(consultationAddressController.text),
        consultationLatitude: _consultationLatitude,
        consultationLongitude: _consultationLongitude,
        consultationInstructions: _nullableTrim(
          consultationInstructionsController.text,
        ),
        isAvailable: existingProfile?.isAvailable ?? true,
        isVerified: existingProfile?.isVerified ?? false,
        createdAt: existingProfile?.createdAt,
        updatedAt: existingProfile?.updatedAt,
      );

      await _repository
          .saveNutritionistProfile(profile)
          .timeout(const Duration(seconds: 15));

      _currentProfile = profile;
      notifyListeners();

      return true;
    } catch (e, stackTrace) {
      _logger.severe('Error guardando perfil', e, stackTrace);
      _setError('No se pudo guardar el perfil. ${friendlyErrorMessage(e)}');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  String? validateRequired(String? value, String field) {
    if ((value ?? '').trim().isEmpty) {
      return 'Ingresa $field';
    }

    return null;
  }

  String? validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) return null;

    if (digits.length != 10) {
      return 'Ingresa 10 dígitos para el celular';
    }

    return null;
  }

  String? validateLicenseNumber(String? value) {
    return ProfessionalRegistryUtils.validateProfessionalLicense(
      registryType: _professionalRegistryType,
      value: value,
    );
  }

  String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    if (_parseOptionalPrice(value) == null) {
      return 'Ingresa un precio válido';
    }

    return null;
  }

  String? validateMeetingLink(String? value) {
    if (_selectedMode == NutritionistConsultationMode.presencial) return null;

    if (value == null || value.trim().isEmpty) return null;

    final link = value.trim();

    if (!link.startsWith('http://') && !link.startsWith('https://')) {
      return 'Ingresa un enlace válido';
    }

    return null;
  }

  String? validateConsultationAddress(String? value) {
    if (_selectedMode == NutritionistConsultationMode.virtual) return null;

    if (value == null || value.trim().isEmpty) return null;

    if (!hasSelectedLocation) return 'Selecciona la ubicación';

    return null;
  }

  void clearError() {
    if (_errorMessage == null) return;

    _errorMessage = null;
    notifyListeners();
  }

  String _localEcuadorPhone(String? value) {
    final raw = value?.trim() ?? '';
    final digits = raw.replaceAll(RegExp(r'\D'), '');

    if (raw.startsWith('+593') && digits.length == 12) {
      return '0${digits.substring(3)}';
    }

    if (digits.startsWith('593') && digits.length == 12) {
      return '0${digits.substring(3)}';
    }

    return digits.length <= 10 ? digits : raw;
  }

  String? _nullableTrim(String value) {
    final trimmed = value.trim();

    return trimmed.isEmpty ? null : trimmed;
  }

  double? _parseOptionalPrice(String? value) {
    if ((value ?? '').trim().isEmpty) return null;

    final parsed = double.tryParse(value?.trim() ?? '');

    if (parsed == null || parsed <= 0) return null;

    return parsed;
  }

  void _fillController(TextEditingController controller, String? value) {
    controller.text = value ?? '';
  }

  void _setLoadingProfile(bool value) {
    if (_isLoadingProfile == value) return;

    _isLoadingProfile = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    if (_isSaving == value) return;

    _isSaving = value;
    notifyListeners();
  }

  void _setUploadingImage(bool value) {
    if (_isUploadingImage == value) return;

    _isUploadingImage = value;
    notifyListeners();
  }

  void _setError(String? message) {
    if (_errorMessage == message) return;

    _errorMessage = message;
    notifyListeners();
  }

  void _setLoadError(String? message) {
    if (_loadErrorMessage == message) return;

    _loadErrorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    for (final controller in _allControllers) {
      controller.dispose();
    }

    super.dispose();
  }
}
