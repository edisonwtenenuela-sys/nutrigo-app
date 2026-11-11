import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emprendedor/core/services/auth/user_session_service.dart';
import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/business_profile_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/profile_controller.dart';
import 'package:emprendedor/features/client/controllers/client_location_picker_controller.dart';
import 'package:emprendedor/features/entrepreneur/helpers/index.dart';

class BusinessProfileEditFeedback {
  const BusinessProfileEditFeedback({
    required this.message,
    required this.type,
  });

  final String message;
  final BusinessProfileEditFeedbackType type;

  String get title {
    return switch (type) {
      BusinessProfileEditFeedbackType.success => 'Perfil guardado',
      BusinessProfileEditFeedbackType.error => 'No se pudo guardar',
      BusinessProfileEditFeedbackType.warning => 'Atención',
      BusinessProfileEditFeedbackType.info => 'Información',
    };
  }
}

enum BusinessProfileEditFeedbackType { success, error, warning, info }

class BusinessProfileEditController extends ChangeNotifier {
  BusinessProfileEditController({
    required this.userId,
    UserSessionService? sessionService,
    ImagePicker? imagePicker,
  }) : _sessionService = sessionService ?? UserSessionService(),
       _imagePicker = imagePicker ?? ImagePicker() {
    emailController.text = _sessionService.currentSnapshot()?.email ?? '';
    addressController.addListener(_handleAddressChanged);
  }

  final String userId;
  final UserSessionService _sessionService;
  final ImagePicker _imagePicker;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final documentNumberController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final openingHoursController = TextEditingController();

  File? selectedImageFile;
  double? selectedLatitude;
  double? selectedLongitude;

  bool isSaving = false;
  bool isUploadingImage = false;
  bool isDocumentLocked = true;
  bool isDocumentStatusLoading = false;
  String documentType = 'cedula';

  bool _isSettingAddressFromMap = false;
  bool _disposed = false;

  bool get hasMapLocation =>
      selectedLatitude != null && selectedLongitude != null;

  bool get canEditDocument => !isDocumentStatusLoading && !isDocumentLocked;

  bool get isPhoneRegister {
    return _sessionService.currentSnapshot()?.isPhoneOnly ?? false;
  }

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  Future<void> loadUserEmail(ProfileController controller) async {
    try {
      final session = _sessionService.currentSnapshot();
      if (session == null) return;

      final authEmail = session.email?.trim() ?? '';
      final metadata = await controller.loadUserProfileMetadata(
        userId: session.uid,
        fallbackEmail: authEmail,
      );
      final email = metadata.email ?? '';

      if (email.isNotEmpty) emailController.text = email;
      isDocumentLocked = metadata.isVerified;
      isDocumentStatusLoading = false;
      _safeNotify();
    } catch (_) {
      isDocumentLocked = true;
      isDocumentStatusLoading = false;
      _safeNotify();
    }
  }

  void populateFormFromProfile(BusinessProfileModel profile) {
    nameController.text = profile.name;
    documentNumberController.text = profile.documentNumber ?? '';
    documentType =
        profile.documentType ?? _documentTypeFromNumber(profile.documentNumber);
    descriptionController.text = profile.description ?? '';

    _isSettingAddressFromMap = true;
    addressController.text = profile.address ?? '';
    _isSettingAddressFromMap = false;

    phoneController.text = BusinessProfileFormHelper.localEcuadorPhone(
      profile.phone,
    );
    emailController.text = _sessionService.currentSnapshot()?.email ?? '';
    openingHoursController.text = profile.openingHours ?? '';
    selectedLatitude = profile.latitude;
    selectedLongitude = profile.longitude;
    _safeNotify();
  }

  Future<BusinessProfileEditFeedback?> pickImage(
    ProfileController controller,
  ) async {
    if (isUploadingImage) return null;

    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 35,
      maxWidth: 700,
      maxHeight: 700,
    );

    if (picked == null) return null;

    final imageFile = File(picked.path);
    selectedImageFile = imageFile;
    isUploadingImage = true;
    _safeNotify();

    try {
      final success = await controller
          .uploadAndSaveProfileImage(imageFile)
          .timeout(const Duration(seconds: 28));

      if (success) return null;

      return BusinessProfileEditFeedback(
        message: controller.errorMessage ?? 'No se pudo actualizar la imagen.',
        type: BusinessProfileEditFeedbackType.error,
      );
    } catch (e) {
      controller.clearLoadingState();
      controller.setActionError(
        'No se pudo actualizar la imagen. ${friendlyErrorMessage(e)}',
      );

      return BusinessProfileEditFeedback(
        message: 'No se pudo actualizar la imagen. ${friendlyErrorMessage(e)}',
        type: BusinessProfileEditFeedbackType.error,
      );
    } finally {
      selectedImageFile = null;
      isUploadingImage = false;
      _safeNotify();
    }
  }

  void setLocation(SelectedLocationResult result) {
    _isSettingAddressFromMap = true;
    addressController.text = _displayAddressFromLocation(result);
    selectedLatitude = result.latitude;
    selectedLongitude = result.longitude;
    _isSettingAddressFromMap = false;
    _safeNotify();
  }

  Future<BusinessProfileEditFeedback> saveProfile(
    ProfileController controller,
  ) async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return const BusinessProfileEditFeedback(
        message: 'Revisa los campos requeridos.',
        type: BusinessProfileEditFeedbackType.warning,
      );
    }

    isSaving = true;
    _safeNotify();

    try {
      await controller.fetchBusinessProfile().timeout(
        const Duration(seconds: 12),
      );

      final profile = _buildProfileToSave(
        _resolveBaseProfile(controller.businessProfile),
      );
      final success = await controller
          .saveProfile(profile, imageFile: null)
          .timeout(const Duration(seconds: 15));
      String? contactEmailError;

      if (success && isPhoneRegister) {
        final emailUpdated = await controller
            .updateContactEmail(
              userId: userId,
              email: emailController.text.trim(),
            )
            .timeout(const Duration(seconds: 12));

        if (!emailUpdated) {
          contactEmailError = 'No se pudo actualizar el correo de contacto.';
        }
      }

      if (success && contactEmailError == null) {
        return const BusinessProfileEditFeedback(
          message: 'Perfil actualizado correctamente',
          type: BusinessProfileEditFeedbackType.success,
        );
      }

      return BusinessProfileEditFeedback(
        message:
            contactEmailError ??
            controller.errorMessage ??
            'No se pudo guardar el perfil.',
        type: BusinessProfileEditFeedbackType.error,
      );
    } catch (e) {
      return BusinessProfileEditFeedback(
        message: 'No se pudo guardar el perfil. ${friendlyErrorMessage(e)}',
        type: BusinessProfileEditFeedbackType.error,
      );
    } finally {
      isSaving = false;
      _safeNotify();
    }
  }

  static String? validateEmailValue(String? value) {
    final email = (value ?? '').trim();

    if (email.isEmpty) return 'Campo obligatorio';

    final valid = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
    if (!valid) return 'Ingresa un correo válido';

    return null;
  }

  String? validateEmail(String? value) => validateEmailValue(value);

  void updateDocumentType(String value) {
    final maxLength = BusinessProfileFormHelper.documentMaxLength(value);
    documentType = value;
    _trimDocumentIfNeeded(maxLength);
    _safeNotify();
  }

  BusinessProfileModel _resolveBaseProfile(
    BusinessProfileModel? currentProfile,
  ) {
    return currentProfile ??
        BusinessProfileModel(userId: userId, name: '', role: 'emprendedor');
  }

  BusinessProfileModel _buildProfileToSave(BusinessProfileModel baseProfile) {
    return BusinessProfileModel(
      id: baseProfile.id,
      userId: userId,
      name: nameController.text.trim(),
      role: baseProfile.role,
      profileImageUrl: baseProfile.profileImageUrl,
      documentType: canEditDocument ? documentType : baseProfile.documentType,
      documentNumber: canEditDocument
          ? documentNumberController.text.trim()
          : baseProfile.documentNumber,
      description: descriptionController.text.trim(),
      address: addressController.text.trim(),
      latitude: selectedLatitude,
      longitude: selectedLongitude,
      phone: phoneController.text.trim(),
      openingHours: openingHoursController.text.trim(),
      rating: baseProfile.rating,
      totalReviews: baseProfile.totalReviews,
      paymentMethods: baseProfile.paymentMethods,
      socialMediaLinks: baseProfile.socialMediaLinks,
      createdAt: baseProfile.createdAt,
      updatedAt: baseProfile.updatedAt,
    );
  }

  String _documentTypeFromNumber(String? documentNumber) {
    final digits = (documentNumber ?? '').replaceAll(RegExp(r'\D'), '');
    return digits.length == 13 ? 'ruc' : 'cedula';
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  String _displayAddressFromLocation(SelectedLocationResult result) {
    final address = result.address.trim();
    const genericAddresses = {
      'ubicación seleccionada',
      'ubicacion seleccionada',
      'toca el mapa para seleccionar una ubicación',
      'toca el mapa para seleccionar una ubicacion',
    };

    if (address.isNotEmpty &&
        !genericAddresses.contains(address.toLowerCase())) {
      return address;
    }

    return 'Ubicación en mapa (${result.latitude.toStringAsFixed(5)}, ${result.longitude.toStringAsFixed(5)})';
  }

  void _trimDocumentIfNeeded(int maxLength) {
    final digits = _digitsOnly(documentNumberController.text);
    if (digits.length <= maxLength) return;

    documentNumberController.text = digits.substring(0, maxLength);
    documentNumberController.selection = TextSelection.collapsed(
      offset: documentNumberController.text.length,
    );
  }

  void _handleAddressChanged() {
    if (_isSettingAddressFromMap) return;
    if (selectedLatitude == null && selectedLongitude == null) return;

    selectedLatitude = null;
    selectedLongitude = null;
    _safeNotify();
  }

  @override
  void dispose() {
    _disposed = true;
    addressController.removeListener(_handleAddressChanged);
    nameController.dispose();
    documentNumberController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    openingHoursController.dispose();
    super.dispose();
  }
}
