export 'package:emprendedor/core/services/auth/phone_auth_service.dart'
    show PhoneAuthSignInResult;
import 'package:flutter/material.dart';
import 'package:emprendedor/core/services/auth/phone_auth_service.dart';
import 'package:emprendedor/core/services/auth/registration/phone_auth_profile_service.dart';
import 'package:emprendedor/core/utils/auth/phone_auth_helpers.dart';
import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:emprendedor/features/auth/helpers/phone_auth_constants.dart';

enum PhoneAuthDestination {
  authWrapper,
  clientProfile,
  entrepreneurSetup,
  nutritionistRegistration,
}

class PhoneAuthCompletion {
  const PhoneAuthCompletion({required this.destination, required this.userId});

  final PhoneAuthDestination destination;
  final String userId;
}

class PhoneAuthController extends ChangeNotifier {
  PhoneAuthController({
    required this.isLogin,
    required this.selectedRole,
    PhoneAuthService? authService,
    PhoneAuthProfileService? profileService,
  }) : _authService = authService ?? PhoneAuthService(),
       _profileService = profileService ?? PhoneAuthProfileService();

  final bool isLogin;
  final String selectedRole;
  final PhoneAuthService _authService;
  final PhoneAuthProfileService _profileService;

  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final ageController = TextEditingController();
  final dietaryGoalController = TextEditingController();
  final documentNumberController = TextEditingController();
  final businessDescriptionController = TextEditingController();
  final specialtyController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final professionalDescriptionController = TextEditingController();
  final nutritionistEmailController = TextEditingController();
  final contactEmailController = TextEditingController();

  String verificationId = '';
  String? errorMessage;
  bool otpSent = false;
  bool isLoading = false;

  String documentType = 'cedula';

  bool _disposed = false;

  int get expectedPhoneDigits => phoneAuthExpectedDigits;
  int get documentDigitLimit => documentType == 'ruc' ? 13 : 10;

  int get smsCurrentStep {
    if (otpSent && isLoading) return 3;
    if (otpSent) return 2;
    return 1;
  }

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_disposed || isLoading == value) return;
    isLoading = value;
    _safeNotify();
  }

  void _setError(String? message) {
    if (_disposed || errorMessage == message) return;
    errorMessage = message;
    _safeNotify();
  }

  void changeDocumentType(String value) {
    documentType = value;
    _trimControllerToDigits(
      documentNumberController,
      maxLength: documentDigitLimit,
    );
    _safeNotify();
  }

  Future<void> sendVerificationCode({
    required Future<void> Function(PhoneAuthSignInResult result)
    onVerificationCompleted,
    required void Function(String message, {required bool isError}) onFeedback,
  }) async {
    if (isLoading) return;

    final phone = phoneDigitsOnly(phoneController.text);

    if (phone.length != expectedPhoneDigits) {
      onFeedback(
        'Ingresa un número celular ecuatoriano válido de 9 dígitos.',
        isError: true,
      );
      return;
    }

    final fullPhoneNumber = '$phoneAuthCountryCode$phone';

    _setLoading(true);
    _setError(null);

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        onVerificationCompleted: onVerificationCompleted,
        onVerificationFailed: (message) {
          _setError(message);
          _setLoading(false);
          onFeedback(message, isError: true);
        },
        onCodeSent: (String newVerificationId, int? resendToken) {
          verificationId = newVerificationId;
          otpSent = true;
          isLoading = false;
          errorMessage = null;
          _safeNotify();
          onFeedback('Código enviado al número celular.', isError: false);
        },
        onAutoRetrievalTimeout: (String newVerificationId) {
          verificationId = newVerificationId;
          isLoading = false;
          _safeNotify();
        },
      );
    } on PhoneAuthFailure catch (e) {
      _setError(e.message);
      _setLoading(false);
      onFeedback(e.message, isError: true);
    }
  }

  Future<PhoneAuthCompletion?> verifyOtp({
    required void Function(String message, {required bool isError}) onFeedback,
  }) async {
    if (isLoading) return null;

    final otp = otpController.text.trim();

    if (otp.isEmpty || otp.length < 6) {
      onFeedback('Ingresa un código de verificación válido.', isError: true);
      return null;
    }

    if (verificationId.isEmpty) {
      onFeedback('Primero solicita un código de verificación.', isError: true);
      return null;
    }

    try {
      final result = await _authService.signInWithSmsCode(
        verificationId: verificationId,
        smsCode: otp,
      );

      return completePhoneSignIn(result: result, onFeedback: onFeedback);
    } on PhoneAuthFailure catch (e) {
      _setError(e.message);
      onFeedback(e.message, isError: true);
      return null;
    }
  }

  Future<PhoneAuthCompletion?> completePhoneSignIn({
    required PhoneAuthSignInResult result,
    required void Function(String message, {required bool isError}) onFeedback,
  }) async {
    if (!isLoading) _setLoading(true);
    _setError(null);

    try {
      if (result.isNewUser) {
        if (selectedRole == 'cliente') {
          await _saveProfileByRole(userId: result.userId);
        } else {
          await _initializePhoneAuthUser(userId: result.userId);
        }

        onFeedback(
          selectedRole == 'nutricionista'
              ? 'Registro exitoso. Completa tu perfil para revisión del administrador.'
              : 'Registro exitoso con teléfono.',
          isError: false,
        );
      } else {
        onFeedback('Inicio de sesión exitoso.', isError: false);
      }

      if (!isLogin) {
        if (selectedRole == 'cliente') {
          return PhoneAuthCompletion(
            destination: PhoneAuthDestination.clientProfile,
            userId: result.userId,
          );
        }

        if (selectedRole == 'emprendedor') {
          return PhoneAuthCompletion(
            destination: PhoneAuthDestination.entrepreneurSetup,
            userId: result.userId,
          );
        }

        if (selectedRole == 'nutricionista') {
          return PhoneAuthCompletion(
            destination: PhoneAuthDestination.nutritionistRegistration,
            userId: result.userId,
          );
        }
      }

      await _authService.waitForAuthenticatedUser();

      return PhoneAuthCompletion(
        destination: PhoneAuthDestination.authWrapper,
        userId: result.userId,
      );
    } catch (e) {
      final message = _registrationErrorMessage(e);
      _setError(message);
      onFeedback(message, isError: true);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _initializePhoneAuthUser({required String userId}) async {
    await _profileService.initializePhoneAuthUser(
      selectedRole: selectedRole,
      userId: userId,
      phoneCode: phoneAuthCountryCode,
      phone: phoneDigitsOnly(phoneController.text),
    );
  }

  Future<void> _saveProfileByRole({
    required String userId,
    String? name,
  }) async {
    await _profileService.saveProfileByRole(
      selectedRole: selectedRole,
      userId: userId,
      name: name ?? nameController.text.trim(),
      phoneCode: phoneAuthCountryCode,
      phone: phoneDigitsOnly(phoneController.text),
      address: addressController.text.trim(),
      ageText: ageController.text.trim(),
      dietaryGoal: dietaryGoalController.text.trim(),
      documentType: documentType,
      documentNumber: documentNumberController.text.trim(),
      businessDescription: businessDescriptionController.text.trim(),
      specialty: specialtyController.text.trim(),
      licenseNumber: licenseNumberController.text.trim(),
      professionalDescription: professionalDescriptionController.text.trim(),
      contactEmail: selectedRole == 'nutricionista'
          ? nutritionistEmailController.text.trim()
          : contactEmailController.text.trim(),
    );
  }

  void _trimControllerToDigits(
    TextEditingController controller, {
    required int maxLength,
  }) {
    final digits = phoneDigitsOnly(controller.text);

    if (digits.length <= maxLength) return;

    controller.text = digits.substring(0, maxLength);
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
  }

  String _registrationErrorMessage(Object error) {
    final raw = error.toString();

    if (raw.contains('permission-denied')) {
      return 'Permisos insuficientes en Firestore para completar el registro.';
    }

    if (raw.contains('userId es requerido')) {
      return 'No se pudo completar el registro: falta identificador de usuario.';
    }

    return 'No se pudo guardar el registro. ${friendlyErrorMessage(error)}';
  }

  @override
  void dispose() {
    _disposed = true;
    phoneController.dispose();
    otpController.dispose();
    nameController.dispose();
    addressController.dispose();
    ageController.dispose();
    dietaryGoalController.dispose();
    documentNumberController.dispose();
    businessDescriptionController.dispose();
    specialtyController.dispose();
    licenseNumberController.dispose();
    professionalDescriptionController.dispose();
    nutritionistEmailController.dispose();
    contactEmailController.dispose();
    super.dispose();
  }
}
