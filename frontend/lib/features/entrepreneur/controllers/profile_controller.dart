import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/core/services/auth/user_session_service.dart';
import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/business_profile_model.dart';
import 'package:emprendedor/data/repositories/entrepreneur/profile/business_profile_repository.dart';

class ProfileController extends ChangeNotifier {
  final Logger _logger = Logger('ProfileController');
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final UserSessionService _sessionService = UserSessionService();
  final BusinessProfileRepository _repository = BusinessProfileRepository();

  BusinessProfileModel? _profile;
  bool _isLoading = false;
  String? _error;
  String? _userId;

  BusinessProfileModel? get businessProfile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _error;
  bool get hasProfile => _profile != null;
  String? get userId => _userId;

  Future<void> setUserId(String? userId) async {
    if (_userId == userId) return;

    _userId = userId;

    if (_userId == null || _userId!.trim().isEmpty) {
      await reset();
      return;
    }

    await fetchBusinessProfile();
  }

  Future<void> reset() async {
    _profile = null;
    _error = null;
    _userId = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBusinessProfile() async {
    if (_userId == null || _userId!.trim().isEmpty) {
      _setError('Usuario no autenticado.');
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      final data = await _repository
          .getBusinessProfile(_userId!)
          .timeout(const Duration(seconds: 12));
      _profile = data;
    } catch (e, st) {
      _logger.severe('Error cargando perfil', e, st);
      _setError('No se pudo cargar el perfil. ${friendlyErrorMessage(e)}');
    } finally {
      _setLoading(false);
    }
  }

  Future<({String? email, bool isVerified})> loadUserProfileMetadata({
    required String userId,
    String? fallbackEmail,
  }) {
    return _repository
        .loadUserProfileMetadata(userId: userId, fallbackEmail: fallbackEmail)
        .timeout(const Duration(seconds: 12));
  }

  Future<bool> updateContactEmail({
    required String userId,
    required String email,
  }) async {
    try {
      await _repository
          .updateContactEmail(userId: userId, email: email)
          .timeout(const Duration(seconds: 12));
      return true;
    } catch (e, st) {
      _logger.severe('Error actualizando correo de contacto', e, st);
      _setError(
        'No se pudo actualizar el correo de contacto. ${friendlyErrorMessage(e)}',
      );
      return false;
    }
  }

  Future<bool> saveProfile(
    BusinessProfileModel profile, {
    File? imageFile,
  }) async {
    final session = _sessionService.currentSnapshot();

    if (session == null) {
      _setError('Usuario no autenticado.');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      String? imageUrl = profile.profileImageUrl;

      if (imageFile != null) {
        imageUrl = await _uploadImage(session.uid, imageFile);
        await _sessionService
            .updateCurrentPhotoUrl(imageUrl)
            .timeout(const Duration(seconds: 10));
      }

      final updated = profile.copyWith(
        id: session.uid,
        userId: session.uid,
        role: 'emprendedor',
        profileImageUrl: imageUrl,
      );

      await _repository
          .saveBusinessProfile(updated)
          .timeout(const Duration(seconds: 12));

      _profile = updated;
      notifyListeners();

      return true;
    } catch (e, st) {
      _logger.severe('Error guardando perfil', e, st);
      _setError('No se pudo guardar el perfil. ${friendlyErrorMessage(e)}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> uploadAndSaveProfileImage(File imageFile) async {
    final session = _sessionService.currentSnapshot();

    if (session == null) {
      _setError('Usuario no autenticado.');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final currentProfile =
          _profile ??
          await _repository
              .getBusinessProfile(session.uid)
              .timeout(const Duration(seconds: 12)) ??
          BusinessProfileModel(
            id: session.uid,
            userId: session.uid,
            name: session.displayName ?? '',
            role: 'emprendedor',
          );

      final imageUrl = await _uploadImage(session.uid, imageFile);
      await _sessionService
          .updateCurrentPhotoUrl(imageUrl)
          .timeout(const Duration(seconds: 10));

      final updated = currentProfile.copyWith(
        id: session.uid,
        userId: session.uid,
        role: 'emprendedor',
        profileImageUrl: imageUrl,
      );

      await _repository
          .saveBusinessProfile(updated)
          .timeout(const Duration(seconds: 12));

      _profile = updated;
      notifyListeners();

      return true;
    } catch (e, st) {
      _logger.severe('Error actualizando imagen de perfil', e, st);
      _setError('No se pudo actualizar la imagen. ${friendlyErrorMessage(e)}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String> _uploadImage(String userId, File file) async {
    final path =
        'profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final ref = _storage.ref().child(path);

    final snapshot = await ref
        .putFile(file, SettableMetadata(contentType: 'image/jpeg'))
        .timeout(const Duration(seconds: 20));

    return snapshot.ref.getDownloadURL().timeout(const Duration(seconds: 10));
  }

  void clearLoadingState() {
    if (!_isLoading) return;
    _isLoading = false;
    notifyListeners();
  }

  void setActionError(String message) {
    _setError(message);
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    if (_error == value) return;
    _error = value;
    notifyListeners();
  }
}
