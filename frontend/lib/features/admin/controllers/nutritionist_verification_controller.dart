import 'dart:async';

import 'package:flutter/material.dart';

import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:emprendedor/data/models/admin/nutritionist_verification_request_model.dart';
import 'package:emprendedor/data/repositories/admin/nutritionist_verification_repository.dart';

class NutritionistVerificationController extends ChangeNotifier {
  final NutritionistVerificationRepository _repository =
      NutritionistVerificationRepository();

  List<NutritionistVerificationRequestModel> _requests = [];
  List<NutritionistVerificationRequestModel> get requests => _requests;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription<List<NutritionistVerificationRequestModel>>? _subscription;

  Future<void> listenPendingRequests() async {
    _setLoading(true);
    _clearError();

    await _subscription?.cancel();

    _subscription = _repository.getPendingRequests().listen(
      (data) {
        _requests = data;
        _setLoading(false);
        _clearError();
        notifyListeners();
      },
      onError: (error) {
        _setError(
          'Error al cargar solicitudes de nutricionistas: ${error.toString()}',
        );
        _setLoading(false);
      },
    );
  }

  Future<bool> approveRequest(
    NutritionistVerificationRequestModel request,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.approveRequest(
        requestId: request.id,
        userId: request.userId,
      );

      return true;
    } catch (e) {
      _setError('No se pudo aprobar la solicitud. ${friendlyErrorMessage(e)}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> canReviewRequest(
    NutritionistVerificationRequestModel request,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.verifyRequestCanBeReviewed(
        requestId: request.id,
        userId: request.userId,
      );
      return true;
    } catch (e) {
      _setError('No se pudo revisar la solicitud. ${friendlyErrorMessage(e)}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> rejectRequest(
    NutritionistVerificationRequestModel request, {
    required String reason,
  }) async {
    final normalizedReason = reason.trim();
    if (normalizedReason.length < 8) {
      _setError('Ingresa un motivo claro para el rechazo.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await _repository.rejectRequest(
        requestId: request.id,
        userId: request.userId,
        reason: normalizedReason,
      );

      return true;
    } catch (e) {
      _setError('No se pudo rechazar la solicitud. ${friendlyErrorMessage(e)}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
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
