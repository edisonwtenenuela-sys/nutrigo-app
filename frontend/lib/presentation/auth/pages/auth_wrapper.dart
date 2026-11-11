import 'package:flutter/material.dart';
import 'package:emprendedor/data/models/client/client_profile_model.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/business_profile_model.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';
import 'package:emprendedor/features/auth/controllers/auth_controller.dart';
import 'package:emprendedor/features/auth/controllers/auth_session_controller.dart';
import 'package:emprendedor/presentation/admin/pages/admin_home_page.dart';
import 'package:emprendedor/presentation/auth/helpers/auth_role_normalizer.dart';
import 'package:emprendedor/presentation/auth/pages/auth_landing_page.dart';
import 'package:emprendedor/presentation/auth/widgets/common/auth_error_screen.dart';
import 'package:emprendedor/presentation/auth/widgets/common/auth_loading_screen.dart';
import 'package:emprendedor/presentation/client/home/pages/client_home_page.dart';
import 'package:emprendedor/presentation/client/profile/pages/client_profile_basic_form_page.dart';
import 'package:emprendedor/presentation/entrepreneur/home/pages/entrepreneur_main_shell.dart';
import 'package:emprendedor/presentation/entrepreneur/profile/pages/index.dart';
import 'package:emprendedor/presentation/nutritionist/home/pages/nutritionist_main_shell.dart';
import 'package:emprendedor/presentation/nutritionist/profile/pages/nutritionist_professional_registration_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthController _authController = AuthController();
  final AuthSessionController _sessionController = AuthSessionController();

  static const Duration _profileResolveTimeout = Duration(seconds: 12);

  String? _profileUserId;
  Future<Map<String, dynamic>?>? _profileFuture;

  Future<Map<String, dynamic>?> _loadProfileWithRetry(String userId) {
    return _authController.loadProfile(userId);
  }

  Future<Map<String, dynamic>?> _profileLoaderFor(String userId) {
    if (_profileUserId != userId || _profileFuture == null) {
      _profileUserId = userId;
      _profileFuture = _loadProfileWithRetry(
        userId,
      ).timeout(_profileResolveTimeout, onTimeout: () => null);
    }

    return _profileFuture!;
  }

  void _clearProfileCache() {
    _profileUserId = null;
    _profileFuture = null;
  }

  Widget _recoverableAuthError([String? message]) {
    return AuthErrorScreen(
      message:
      message ??
          'No pudimos cargar tu sesión en este momento. Revisa tu conexión e inténtalo nuevamente.',
      onRetry: () {
        _clearProfileCache();

        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget _unauthorizedAccount() {
    return _recoverableAuthError(
      'Esta cuenta no tiene un perfil válido para ingresar. Si crees que es un error, reintenta o cierra sesión.',
    );
  }

  bool _hasEmptyRole(dynamic rawRole) {
    return rawRole == null || rawRole.toString().trim().isEmpty;
  }

  Widget _resolveDestinationByRole({
    required String role,
    required dynamic profile,
    required String userId,
  }) {
    switch (role) {
      case 'admin':
        return const AdminHomePage();

      case 'emprendedor':
        if (profile is BusinessProfileModel &&
            !_authController.isEntrepreneurComplete(profile)) {
          return BusinessProfileSetupPage(userId: userId);
        }
        return const EntrepreneurMainShell();

      case 'cliente':
        if (profile is ClientProfileModel &&
            !_authController.isClientComplete(profile)) {
          return const ClientProfileBasicFormPage();
        }
        return const ClientHomePage();

      case 'pending_nutritionist':
        if (profile is! NutritionistProfileModel ||
            !_authController.isNutritionistProfessionalRegistrationComplete(
              profile,
            )) {
          return const NutritionistProfessionalRegistrationPage();
        }
        return const NutritionistMainShell();

      case 'nutricionista':
        return const NutritionistMainShell();

      default:
        return _unauthorizedAccount();
    }
  }

  Widget _buildProfileResolution(String userId) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _profileLoaderFor(userId),
      builder: (context, profileSnapshot) {
        if (profileSnapshot.connectionState == ConnectionState.waiting) {
          return const AuthLoadingScreen();
        }

        if (profileSnapshot.hasError) {
          return _recoverableAuthError();
        }

        final result = profileSnapshot.data;

        if (result == null) {
          return _recoverableAuthError();
        }

        final rawRole = result['role'];

        if (_hasEmptyRole(rawRole)) {
          return _recoverableAuthError();
        }

        final role = AuthRoleNormalizer.normalize(rawRole);
        final profile = result['profile'];

        return _resolveDestinationByRole(
          role: role,
          profile: profile,
          userId: userId,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: _sessionController.authUserIdChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const AuthLoadingScreen();
        }

        final userId = authSnapshot.data;

        if (userId == null) {
          _clearProfileCache();
          return const AuthLandingPage();
        }

        return _buildProfileResolution(userId);
      },
    );
  }
}