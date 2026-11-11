import 'dart:async';

import 'package:flutter/material.dart';

import 'package:emprendedor/core/services/auth/profile_email_verification_service.dart';

class ProfileEmailVerificationController extends ChangeNotifier {
  ProfileEmailVerificationController({
    ProfileEmailVerificationService? service,
    this.onVerificationChanged,
  }) : _service = service ?? ProfileEmailVerificationService();

  final ProfileEmailVerificationService _service;
  final VoidCallback? onVerificationChanged;
  final TextEditingController emailController = TextEditingController();

  Timer? _verificationTimer;
  bool _isVerified = false;
  bool _isCheckingInitialStatus = true;
  bool _isSendingVerification = false;
  bool _verificationEmailSent = false;
  bool _sessionRecoveryNotified = false;

  String? _pendingEmail;
  String? _storedEmail;
  String? _lastKnownEmail;

  bool get isVerified => _isVerified;
  bool get isCheckingInitialStatus => _isCheckingInitialStatus;
  bool get isSendingVerification => _isSendingVerification;
  bool get verificationEmailSent => _verificationEmailSent;

  ProfileEmailSession? get session => _service.currentSession();

  bool get isPhoneContactMode {
    final user = session;
    return user != null && user.isPhoneOnly;
  }

  bool get isGoogleMode {
    final user = session;
    return user != null && user.isGoogle;
  }

  bool get isEmailPasswordMode {
    final user = session;
    return user != null && user.isPassword;
  }

  bool get hasPending {
    return !isPhoneContactMode &&
        ((_pendingEmail ?? '').isNotEmpty || _verificationEmailSent) &&
        !_isVerified;
  }

  bool get showVerifyButton {
    return isEmailPasswordMode &&
        emailController.text.trim().isNotEmpty &&
        !_isVerified &&
        !_verificationEmailSent;
  }

  bool get showPendingState {
    return isEmailPasswordMode &&
        emailController.text.trim().isNotEmpty &&
        !_isVerified &&
        (_verificationEmailSent || hasPending);
  }

  String get fieldLabel {
    if (isPhoneContactMode) return 'Número verificado';
    if (_isVerified) return 'Correo verificado';
    if (hasPending || _verificationEmailSent) {
      return 'Correo pendiente de verificación';
    }
    return 'Correo electrónico';
  }

  Future<void> initialize() async {
    final user = session;
    final initialValue = isPhoneContactMode
        ? (user?.phoneNumber ?? '').trim()
        : (user?.email ?? '').trim();

    _isVerified = isGoogleMode || (user?.emailVerified ?? false);
    emailController.text = initialValue;

    if (initialValue.isNotEmpty && !isPhoneContactMode) {
      _lastKnownEmail = initialValue;
    }

    await _syncFromAuth();
    await _loadEmailData();

    if (!isPhoneContactMode && !_isVerified) {
      _startVerificationWatcher();
    }

    _isCheckingInitialStatus = false;
    notifyListeners();
  }

  Future<ProfileEmailResumeResult> handleResume() async {
    if (isPhoneContactMode) {
      await _loadEmailData();
      return const ProfileEmailResumeResult.none();
    }

    final hasPendingEmail =
        (_pendingEmail ?? '').trim().isNotEmpty && !_isVerified;
    final user = session;

    if (hasPendingEmail && user == null) {
      if (_sessionRecoveryNotified) {
        return const ProfileEmailResumeResult.none();
      }

      _sessionRecoveryNotified = true;
      return const ProfileEmailResumeResult.sessionRecoveryRequired();
    }

    _sessionRecoveryNotified = false;
    await checkVerificationSilently();
    return const ProfileEmailResumeResult.none();
  }

  Future<ProfileEmailSendResult> sendVerificationEmail() async {
    if (_isSendingVerification) return const ProfileEmailSendResult.none();

    final user = session;

    if (user == null) {
      return const ProfileEmailSendResult.error(
        title: 'Sesión requerida',
        message: 'Inicia sesión nuevamente para enviar la verificación.',
      );
    }

    final email = (user.email ?? emailController.text).trim();

    if (email.isEmpty) {
      return const ProfileEmailSendResult.warning(
        title: 'Correo no disponible',
        message: 'No se encontró un correo asociado a esta cuenta.',
      );
    }

    _setSending(true);

    try {
      await _service.sendVerificationEmail();

      await _service.markVerificationEmailSent(userId: user.uid, email: email);

      _verificationEmailSent = true;
      _pendingEmail = email;
      _startVerificationWatcher();
      notifyListeners();

      return const ProfileEmailSendResult.success(
        title: 'Correo enviado',
        message:
            'Te enviamos un enlace de verificación. Revisa tu bandeja de entrada o spam.',
      );
    } on ProfileEmailVerificationFailure catch (error) {
      return ProfileEmailSendResult.error(
        title: 'No se pudo enviar',
        message: error.message,
      );
    } catch (_) {
      return const ProfileEmailSendResult.error(
        title: 'No se pudo enviar',
        message: 'Ocurrió un error al enviar el correo de verificación.',
      );
    } finally {
      _setSending(false);
    }
  }

  Future<void> checkVerificationSilently() async {
    final user = session;

    if (user == null || isPhoneContactMode) return;

    try {
      final refreshedUser = await _service.reloadCurrentSession();
      final verified = refreshedUser?.emailVerified ?? false;
      final authEmail = (refreshedUser?.email ?? user.email ?? '').trim();
      final pending = (_pendingEmail ?? '').trim();

      if (verified || isGoogleMode) {
        final resolvedEmail = authEmail.isNotEmpty ? authEmail : pending;

        if (resolvedEmail.isEmpty) return;

        final wasVerified = _isVerified;
        _isVerified = true;
        _verificationEmailSent = false;
        _pendingEmail = null;
        _storedEmail = resolvedEmail;
        _lastKnownEmail = resolvedEmail;
        emailController.text = resolvedEmail;
        _verificationTimer?.cancel();
        notifyListeners();

        if (!wasVerified) {
          onVerificationChanged?.call();
        }

        try {
          await _service.markEmailVerified(
            userId: user.uid,
            email: resolvedEmail,
          );
        } catch (_) {}

        return;
      }

      _isVerified = false;

      if (authEmail.isNotEmpty) {
        _lastKnownEmail = authEmail;
        emailController.text = authEmail;
      }

      notifyListeners();
    } catch (_) {}
  }

  Future<void> _syncFromAuth() async {
    final user = session;

    if (user == null) return;

    if (isPhoneContactMode) {
      final phoneNumber = (user.phoneNumber ?? '').trim();
      _isVerified = false;

      if (phoneNumber.isNotEmpty) {
        emailController.text = phoneNumber;
      }

      notifyListeners();
      return;
    }

    ProfileEmailSession? refreshedUser;
    try {
      refreshedUser = await _service.reloadCurrentSession();
    } catch (_) {}

    final verified = refreshedUser?.emailVerified ?? user.emailVerified;
    final authEmail = (refreshedUser?.email ?? user.email ?? '').trim();

    _isVerified = isGoogleMode ? true : verified;

    if (authEmail.isNotEmpty) {
      _lastKnownEmail = authEmail;
      emailController.text = authEmail;
    }

    if (_isVerified) {
      _verificationEmailSent = false;
      _pendingEmail = null;
    }

    notifyListeners();
  }

  Future<void> _loadEmailData() async {
    final user = session;

    if (user == null) return;

    if (isPhoneContactMode) {
      final phoneNumber = (user.phoneNumber ?? '').trim();

      if (phoneNumber.isNotEmpty) {
        emailController.text = phoneNumber;
        notifyListeners();
      }

      return;
    }

    try {
      final emailData = await _service.loadEmailData(user.uid);
      final pending = emailData.pendingEmail;
      final stored = emailData.storedEmail;
      final authEmail = (user.email ?? '').trim();

      _pendingEmail = (pending?.isNotEmpty ?? false) ? pending : null;
      _storedEmail = (stored?.isNotEmpty ?? false) ? stored : null;

      final resolvedEmail = authEmail.isNotEmpty
          ? authEmail
          : (_storedEmail ?? _pendingEmail ?? _lastKnownEmail ?? '');

      if (resolvedEmail.isNotEmpty) {
        _lastKnownEmail = resolvedEmail;
        emailController.text = resolvedEmail;
      }

      notifyListeners();
    } catch (_) {}

    if (!isPhoneContactMode && !_isVerified) {
      _startVerificationWatcher();
    }
  }

  void _startVerificationWatcher() {
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => checkVerificationSilently(),
    );
  }

  void _setSending(bool value) {
    if (_isSendingVerification == value) return;
    _isSendingVerification = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    emailController.dispose();
    super.dispose();
  }
}

enum ProfileEmailResumeAction { none, sessionRecoveryRequired }

class ProfileEmailResumeResult {
  const ProfileEmailResumeResult._(this.action);

  const ProfileEmailResumeResult.none() : this._(ProfileEmailResumeAction.none);

  const ProfileEmailResumeResult.sessionRecoveryRequired()
    : this._(ProfileEmailResumeAction.sessionRecoveryRequired);

  final ProfileEmailResumeAction action;
}

enum ProfileEmailSendType { none, success, warning, error }

class ProfileEmailSendResult {
  const ProfileEmailSendResult._({
    required this.type,
    this.title,
    this.message,
  });

  const ProfileEmailSendResult.none() : this._(type: ProfileEmailSendType.none);

  const ProfileEmailSendResult.success({
    required String title,
    required String message,
  }) : this._(
         type: ProfileEmailSendType.success,
         title: title,
         message: message,
       );

  const ProfileEmailSendResult.warning({
    required String title,
    required String message,
  }) : this._(
         type: ProfileEmailSendType.warning,
         title: title,
         message: message,
       );

  const ProfileEmailSendResult.error({
    required String title,
    required String message,
  }) : this._(type: ProfileEmailSendType.error, title: title, message: message);

  final ProfileEmailSendType type;
  final String? title;
  final String? message;
}








