import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:emprendedor/data/models/client/client_profile_model.dart';
import 'package:emprendedor/data/repositories/client/client_profile_repository.dart';
import 'package:emprendedor/core/services/auth/user_session_service.dart';

class ClientProfileController extends ChangeNotifier {
  final Logger _logger = Logger('ClientProfileController');
  final ClientProfileRepository _repository = ClientProfileRepository();
  final UserSessionService _sessionService = UserSessionService();
  final ImagePicker _picker = ImagePicker();

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final goalController = TextEditingController();
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final allergyInputController = TextEditingController();

  String? selectedGender;
  final List<String> selectedAllergies = [];

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUploadingImage = false;
  bool get isUploadingImage => _isUploadingImage;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ClientProfileModel? _profile;
  String? _loadedUserId;

  ClientProfileModel? get profile => _profile;

  String? get profileImageUrl => _profile?.profileImageUrl;
  bool get isVerified => _profile?.isVerified ?? false;

  double? _latitude;
  double? get latitude => _latitude;

  double? _longitude;
  double? get longitude => _longitude;

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

  void _clearProfileData({bool notify = true}) {
    _profile = null;

    nameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    goalController.clear();
    ageController.clear();
    weightController.clear();
    heightController.clear();
    allergyInputController.clear();
    selectedAllergies.clear();

    selectedGender = null;

    _latitude = null;
    _longitude = null;

    _errorMessage = null;

    _isSaving = false;
    _isLoading = false;
    _isUploadingImage = false;

    if (notify) notifyListeners();
  }

  void loadInitialData(ClientProfileModel? profile) {
    nameController.text = profile?.name ?? '';
    phoneController.text = _localEcuadorPhone(profile?.phone);
    addressController.text = profile?.address ?? '';
    goalController.text = profile?.dietaryGoal ?? '';
    ageController.text = profile?.age?.toString() ?? '';
    weightController.text = profile?.weight?.toString() ?? '';
    heightController.text = profile?.height?.toString() ?? '';
    selectedAllergies
      ..clear()
      ..addAll(profile?.allergies ?? const []);
    selectedGender = profile?.gender;

    _latitude = profile?.latitude;
    _longitude = profile?.longitude;
  }

  Stream<String?> watchPendingEmail(String userId) {
    return _repository.watchPendingEmail(userId);
  }

  Future<void> loadProfile() async {
    final session = _sessionService.currentSnapshot();

    if (session == null) {
      reset();
      _setError('No hay usuario autenticado.');
      return;
    }

    if (_loadedUserId != session.uid) {
      _loadedUserId = session.uid;
      _clearProfileData();
    }

    _setLoading(true);
    _setError(null);

    try {
      final profile = await _repository.getClientProfile(session.uid);
      final storedEmail = await _repository.getUserEmail(session.uid);

      if (_loadedUserId != session.uid) return;

      _profile = profile;
      loadInitialData(profile);

      emailController.text = (storedEmail?.isNotEmpty ?? false)
          ? storedEmail!
          : (session.email ?? '');
    } catch (e, st) {
      _logger.severe('Error cargando perfil cliente', e, st);
      _setError('Error al cargar el perfil.');
    } finally {
      _setLoading(false);
    }
  }

  String? validateRequired(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa $field';
    }

    return null;
  }

  String? validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      return 'Ingresa tu teléfono';
    }

    if (digits.length != 10) {
      return 'Ingresa 10 dígitos para el celular';
    }

    return null;
  }

  String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu edad';
    }

    final age = int.tryParse(value.trim());

    if (age == null || age <= 0 || age > 120) {
      return 'Ingresa una edad válida';
    }

    return null;
  }

  void updateGender(String? value) {
    selectedGender = value;
    _errorMessage = null;
    notifyListeners();
  }

  void setSelectedLocation({
    required String address,
    required double latitude,
    required double longitude,
  }) {
    addressController.text = address;
    _latitude = latitude;
    _longitude = longitude;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> pickAndUploadProfileImage() async {
    final session = _sessionService.currentSnapshot();

    if (session == null) {
      _setError('No hay usuario autenticado.');
      return;
    }

    try {
      final pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 900,
      );

      if (pickedImage == null) return;

      _setUploadingImage(true);
      _setError(null);

      final imageUrl = await _repository
          .uploadProfileImage(
            userId: session.uid,
            imageFile: File(pickedImage.path),
          )
          .timeout(const Duration(seconds: 25));

      await _sessionService
          .updateCurrentPhotoUrl(imageUrl)
          .timeout(const Duration(seconds: 10));

      final age = int.tryParse(ageController.text.trim());
      final weight = double.tryParse(weightController.text.trim());
      final height = double.tryParse(heightController.text.trim());

      final updatedProfile = ClientProfileModel(
        id: session.uid,
        userId: session.uid,
        name: nameController.text.trim(),
        role: 'cliente',
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        profileImageUrl: imageUrl,
        isVerified: _profile?.isVerified ?? true,
        latitude: _latitude,
        longitude: _longitude,
        dietaryGoal: goalController.text.trim(),
        age: age,
        gender: selectedGender,
        weight: weight,
        height: height,
        dietaryPreferences: _profile?.dietaryPreferences ?? const [],
        allergies: List<String>.from(selectedAllergies),
        medicalConditions: _profile?.medicalConditions ?? const [],
      );

      await _repository
          .saveClientProfile(updatedProfile)
          .timeout(const Duration(seconds: 12));

      _profile = updatedProfile;
      _errorMessage = null;

      notifyListeners();
    } catch (e, st) {
      _logger.severe('Error subiendo foto de perfil', e, st);
      _setError(
        'No se pudo subir la foto de perfil. ${friendlyErrorMessage(e)}',
      );
    } finally {
      _setUploadingImage(false);
    }
  }

  Future<bool> sendEmailVerification() async {
    final session = _sessionService.currentSnapshot();

    if (session == null) {
      _setError('No hay usuario autenticado.');
      return false;
    }

    try {
      await _sessionService.sendCurrentUserEmailVerification();
      return true;
    } catch (e, st) {
      _logger.severe('Error enviando correo de verificación', e, st);
      _setError('No se pudo enviar el correo de verificación.');
      return false;
    }
  }

  Future<bool> saveProfile() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return false;
    }

    final session = _sessionService.currentSnapshot();

    if (session == null) {
      _setError('No hay usuario autenticado.');
      return false;
    }

    final age = int.tryParse(ageController.text.trim());
    final weight = double.tryParse(weightController.text.trim());
    final height = double.tryParse(heightController.text.trim());

    if (age == null) {
      _setError('Edad inválida.');
      return false;
    }

    _setError(null);
    _setSaving(true);

    try {
      final refreshedSession = await _sessionService.reloadCurrentSnapshot();

      if (refreshedSession == null) {
        _setError('No hay usuario autenticado.');
        return false;
      }

      final profile = ClientProfileModel(
        id: refreshedSession.uid,
        userId: refreshedSession.uid,
        name: nameController.text.trim(),
        role: 'cliente',
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        profileImageUrl: _profile?.profileImageUrl,
        isVerified: _profile?.isVerified ?? true,
        latitude: _latitude,
        longitude: _longitude,
        dietaryGoal: goalController.text.trim(),
        age: age,
        gender: selectedGender,
        weight: weight,
        height: height,
        allergies: List<String>.from(selectedAllergies),
      );

      await _repository.saveClientProfile(profile);
      await _repository.saveUserEmail(
        userId: refreshedSession.uid,
        email: emailController.text.trim(),
      );

      _profile = profile;
      _loadedUserId = refreshedSession.uid;

      notifyListeners();

      return true;
    } catch (e, st) {
      _logger.severe('Error guardando perfil cliente', e, st);
      _setError('Error al guardar el perfil');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  void toggleAllergy(String allergy) {
    if (selectedAllergies.contains(allergy)) {
      selectedAllergies.remove(allergy);
    } else {
      selectedAllergies.add(allergy);
    }
    _errorMessage = null;
    notifyListeners();
  }

  void addCustomAllergy() {
    final value = allergyInputController.text.trim();
    if (value.isEmpty) return;
    if (!selectedAllergies.contains(value)) {
      selectedAllergies.add(value);
    }
    allergyInputController.clear();
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _loadedUserId = null;
    _clearProfileData();
  }

  void _setSaving(bool value) {
    if (_isSaving == value) return;
    _isSaving = value;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
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

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    goalController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    allergyInputController.dispose();
    super.dispose();
  }
}
