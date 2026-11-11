import 'package:flutter/material.dart';

import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/data/repositories/client/nutritionist_review_repository.dart';

class NutritionistReviewDialogController extends ChangeNotifier {
  final AppointmentModel appointment;
  final NutritionistReviewRepository _repository;
  final TextEditingController commentController = TextEditingController();

  NutritionistReviewDialogController({
    required this.appointment,
    NutritionistReviewRepository? repository,
  }) : _repository = repository ?? NutritionistReviewRepository();

  int _rating = 5;
  int get rating => _rating;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void updateRating(int value) {
    if (_rating == value || _isLoading) return;
    _rating = value;
    notifyListeners();
  }

  Future<bool> submit() async {
    if (_isLoading) return false;

    _setLoading(true);
    _errorMessage = null;

    try {
      await _repository.submitReview(
        appointment: appointment,
        rating: _rating,
        comment: commentController.text,
      );
      _setLoading(false);
      return true;
    } catch (_) {
      _errorMessage =
          'No se pudo guardar la valoración. Revisa tu conexión e inténtalo nuevamente.';
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }
}
