import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/core/services/auth/register_auth_service.dart';
import 'package:emprendedor/core/services/auth/registration/register_account_service.dart';
import 'package:emprendedor/core/services/external_url_launcher_service.dart';
import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:emprendedor/features/auth/helpers/register_role_defaults.dart';

class RegisterCompletion {
  const RegisterCompletion({
    required this.userId,
    required this.selectedRole,
    required this.message,
    required this.shouldOpenAuthWrapper,
  });

  final String userId;
  final String selectedRole;
  final String message;
  final bool shouldOpenAuthWrapper;
}

class RegisterController extends ChangeNotifier {
  RegisterController({
    RegisterAuthService? authService,
    RegisterAccountService? accountService,
    ExternalUrlLauncherService? urlLauncher,
  }) : _authService = authService ?? RegisterAuthService(),
       _accountService = accountService ?? RegisterAccountService(),
       _urlLauncher = urlLauncher ?? const ExternalUrlLauncherService();

  final RegisterAuthService _authService;
  final RegisterAccountService _accountService;
  final ExternalUrlLauncherService _urlLauncher;
  final Logger logger = Logger('RegisterController');

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final ageController = TextEditingController();
  final dietaryGoalController = TextEditingController();
  final documentNumberController = TextEditingController();
  final businessDescriptionController = TextEditingController();
  final specialtyController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final professionalDescriptionController = TextEditingController();

  String? errorMessage;
  bool isLoading = false;
  String selectedRole = 'emprendedor';
  String documentType = 'cedula';

  bool _disposed = false;

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  void clearError() {
    if (errorMessage == null) return;
    errorMessage = null;
    _safeNotify();
  }

  void _setLoading(bool value) {
    if (_disposed || isLoading == value) return;
    isLoading = value;
    _safeNotify();
  }

  void _setError(String message) {
    if (_disposed) return;
    errorMessage = message;
    _safeNotify();
  }

  void updateSelectedRole(String role) {
    selectedRole = role;
    _safeNotify();
  }

  void updateDocumentType(String value) {
    final maxLength = value == 'ruc' ? 13 : 10;
    documentType = value;
    _trimDocumentToLimit(maxLength);
    _safeNotify();
  }

  Future<bool> openLegalUrl(String url) {
    return _urlLauncher.openExternalUrl(url);
  }

  Future<RegisterCompletion?> registerWithEmail({
    required void Function(String message, {required bool isError}) onFeedback,
  }) async {
    if (isLoading) return null;
    if (!(formKey.currentState?.validate() ?? false)) return null;

    _setLoading(true);
    clearError();

    try {
      final authResult = await _authService.createWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final defaultName = _defaultName(authResult.displayName);

      await _saveInitialUserData(
        userId: authResult.userId,
        email: authResult.email,
        defaultName: defaultName,
      );

      final message = _roleSuccessMessage(withGoogleLabel: false);
      onFeedback(message, isError: false);

      return RegisterCompletion(
        userId: authResult.userId,
        selectedRole: selectedRole,
        message: message,
        shouldOpenAuthWrapper: false,
      );
    } on RegisterAuthFailure catch (e) {
      _setError(e.message);
      onFeedback(e.message, isError: true);
      logger.severe('Error de autenticación al registrar: ${e.message}');
      return null;
    } catch (e, st) {
      final message = _registrationErrorMessage(e);
      _setError(message);
      onFeedback(message, isError: true);
      logger.severe('Error general al registrar con email', e, st);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<RegisterCompletion?> registerWithGoogle({
    required void Function(String message, {required bool isError}) onFeedback,
  }) async {
    if (isLoading) return null;

    _setLoading(true);
    clearError();

    try {
      final authResult = await _authService.signInWithGoogle();
      if (authResult == null) return null;

      if (authResult.isNewUser) {
        final defaultName = _defaultName(authResult.displayName);

        await _saveInitialUserData(
          userId: authResult.userId,
          email: authResult.email,
          defaultName: defaultName,
        );

        final message = _roleSuccessMessage(withGoogleLabel: true);
        onFeedback(message, isError: false);

        return RegisterCompletion(
          userId: authResult.userId,
          selectedRole: selectedRole,
          message: message,
          shouldOpenAuthWrapper: false,
        );
      }

      await _authService.waitForAuthenticatedUser();
      const message = 'Inicio de sesión con Google exitoso.';
      onFeedback(message, isError: false);

      return RegisterCompletion(
        userId: authResult.userId,
        selectedRole: selectedRole,
        message: message,
        shouldOpenAuthWrapper: true,
      );
    } on RegisterAuthFailure catch (e) {
      _setError(e.message);
      onFeedback(e.message, isError: true);
      logger.severe('Error de autenticación con Google: ${e.message}');
      return null;
    } catch (e, st) {
      final message =
          'No se pudo continuar con Google. ${friendlyErrorMessage(e)}';
      _setError(message);
      onFeedback(message, isError: true);
      logger.severe('Error general en Google Sign-In', e, st);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  String _defaultName(String? authDisplayName) {
    final typedName = nameController.text.trim();
    if (typedName.isNotEmpty) return typedName;
    return authDisplayName ??
        RegisterRoleDefaults.defaultNameByRole(selectedRole);
  }

  String _roleSuccessMessage({required bool withGoogleLabel}) {
    if (selectedRole == 'nutricionista') {
      return 'Registro exitoso. Tu perfil será revisado por el administrador.';
    }

    return withGoogleLabel
        ? 'Registro exitoso con Google.'
        : 'Registro exitoso.';
  }

  Future<void> _saveInitialUserData({
    required String userId,
    required String email,
    required String defaultName,
  }) async {
    await _accountService.saveUserDocument(
      selectedRole: selectedRole,
      userId: userId,
      email: email,
      name: defaultName,
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      documentType: documentType,
      documentNumber: documentNumberController.text.trim(),
      licenseNumber: licenseNumberController.text.trim(),
    );
  }

  String _registrationErrorMessage(Object error) {
    final raw = error.toString();
    if (raw.contains('permission-denied')) {
      return 'Permisos insuficientes en Firestore para completar el registro.';
    }

    return 'No se pudo registrar la cuenta. ${friendlyErrorMessage(error)}';
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  void _trimDocumentToLimit(int maxLength) {
    final digits = _digitsOnly(documentNumberController.text);
    if (digits.length <= maxLength) return;

    documentNumberController.text = digits.substring(0, maxLength);
    documentNumberController.selection = TextSelection.collapsed(
      offset: documentNumberController.text.length,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    ageController.dispose();
    dietaryGoalController.dispose();
    documentNumberController.dispose();
    businessDescriptionController.dispose();
    specialtyController.dispose();
    licenseNumberController.dispose();
    professionalDescriptionController.dispose();
    super.dispose();
  }
}
