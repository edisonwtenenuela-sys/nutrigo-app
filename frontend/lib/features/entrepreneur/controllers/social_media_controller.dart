import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/social_media_model.dart';
import 'package:emprendedor/data/repositories/entrepreneur/profile/social_media_repository.dart';

class SocialMediaController extends ChangeNotifier {
  final Logger _logger = Logger('SocialMediaController');
  final SocialMediaRepository _repository = SocialMediaRepository();

  List<SocialMediaModel> _socialMediaList = [];
  List<SocialMediaModel> get socialMediaList => _socialMediaList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription<List<SocialMediaModel>>? _subscription;
  String? _userId;

  Future<void> setUserId(String? userId) async {
    if (_userId == userId) return;

    await _subscription?.cancel();
    _subscription = null;

    _userId = userId;
    _socialMediaList = [];
    _errorMessage = null;

    if (_userId == null) {
      _setLoading(false);
      notifyListeners();
      return;
    }

    await fetchSocialMediaLinks();
  }

  Future<void> fetchSocialMediaLinks() async {
    if (_userId == null) {
      _setError('Usuario no autenticado.');
      return;
    }

    _setLoading(true);
    _clearError();

    await _subscription?.cancel();

    try {
      _subscription = _repository
          .getSocialMediaLinks(_userId!)
          .listen(
            (data) {
              _socialMediaList = data;
              _setLoading(false);
            },
            onError: (error, stackTrace) {
              _logger.severe(
                'Error al cargar enlaces de redes sociales',
                error,
                stackTrace,
              );
              _setError('Error al cargar enlaces de redes sociales.');
              _setLoading(false);
            },
          );
    } catch (e, st) {
      _logger.severe('Excepcion al iniciar la carga de redes sociales', e, st);
      _setError('Error al cargar enlaces de redes sociales.');
      _setLoading(false);
    }
  }

  Future<bool> addSocialMedia(SocialMediaModel socialMedia) async {
    if (_userId == null) {
      _setError('Usuario no autenticado.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await _repository.addSocialMedia(_userId!, socialMedia);
      return true;
    } catch (e, st) {
      _logger.severe('Error al agregar red social', e, st);
      _setError('No se pudo agregar la red social. ${friendlyErrorMessage(e)}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateSocialMedia(SocialMediaModel socialMedia) async {
    if (_userId == null) {
      _setError('Usuario no autenticado.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await _repository.updateSocialMedia(_userId!, socialMedia);
      return true;
    } catch (e, st) {
      _logger.severe('Error al actualizar red social', e, st);
      _setError(
        'No se pudo actualizar la red social. ${friendlyErrorMessage(e)}',
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteSocialMedia(String docId) async {
    if (_userId == null) {
      _setError('Usuario no autenticado.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await _repository.deleteSocialMedia(_userId!, docId);
      return true;
    } catch (e, st) {
      _logger.severe('Error al eliminar red social', e, st);
      _setError(
        'No se pudo eliminar la red social. ${friendlyErrorMessage(e)}',
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _clearError();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    if (_errorMessage == message) return;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
