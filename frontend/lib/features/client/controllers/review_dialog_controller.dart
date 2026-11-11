import 'package:flutter/material.dart';

class ReviewDialogController extends ChangeNotifier {
  final TextEditingController commentController = TextEditingController();

  int _rating = 5;
  int get rating => _rating;

  void updateRating(int value) {
    if (_rating == value) return;
    _rating = value;
    notifyListeners();
  }

  ReviewDialogResult buildResult() {
    return ReviewDialogResult(
      rating: _rating.toDouble(),
      comment: commentController.text.trim(),
    );
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }
}

class ReviewDialogResult {
  final double rating;
  final String comment;

  const ReviewDialogResult({required this.rating, required this.comment});
}








