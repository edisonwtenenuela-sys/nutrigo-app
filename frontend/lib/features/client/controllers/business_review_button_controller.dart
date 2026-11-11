import 'package:flutter/material.dart';

import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:emprendedor/data/models/client/business_review_model.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/data/repositories/client/business_review_repository.dart';
import 'package:emprendedor/data/repositories/shared/order_repository.dart';
import 'package:emprendedor/features/client/controllers/client_order_business_controller.dart';
import 'package:emprendedor/features/client/controllers/client_product_card_controller.dart';
import 'package:emprendedor/features/client/controllers/client_products_controller.dart';

class BusinessReviewButtonController extends ChangeNotifier {
  final OrderModel order;
  final BusinessReviewRepository _reviewRepository;
  final OrderRepository _orderRepository;

  BusinessReviewButtonController({
    required this.order,
    BusinessReviewRepository? reviewRepository,
    OrderRepository? orderRepository,
  }) : _reviewRepository = reviewRepository ?? BusinessReviewRepository(),
       _orderRepository = orderRepository ?? OrderRepository();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _hasReviewed = false;
  bool get hasReviewed => _hasReviewed;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadReviewState() async {
    try {
      final orderId = order.id;

      if (orderId == null) {
        _setLoading(false);
        return;
      }

      _hasReviewed = await _reviewRepository.hasReviewedOrder(
        orderId: orderId,
        clientUserId: order.userId,
      );
      _setLoading(false);
    } catch (_) {
      _hasReviewed = false;
      _setLoading(false);
    }
  }

  Future<bool> submitReview({
    required double rating,
    required String comment,
  }) async {
    final orderId = order.id;

    if (orderId == null || _isSubmitting) return false;

    _setSubmitting(true);
    _errorMessage = null;

    try {
      final review = BusinessReviewModel(
        orderId: orderId,
        businessUserId: order.businessUserId,
        clientUserId: order.userId,
        clientName: order.customerInfo.name.trim(),
        clientProfileImageUrl: order.customerInfo.profileImageUrl,
        rating: rating,
        comment: comment,
      );

      await _reviewRepository.addReview(review);
      await _refreshBusinessSummaryCache(order.businessUserId);

      _hasReviewed = true;
      _setSubmitting(false);
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = _reviewErrorMessage(error);
      _setSubmitting(false);
      return false;
    }
  }

  String _reviewErrorMessage(Object error) {
    final detail = friendlyErrorMessage(
      error,
      fallback: 'Ocurrió un problema inesperado. Inténtalo nuevamente.',
    );
    return 'No se pudo guardar la reseña. $detail';
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setSubmitting(bool value) {
    if (_isSubmitting == value) return;
    _isSubmitting = value;
    notifyListeners();
  }

  Future<void> _refreshBusinessSummaryCache(String businessUserId) async {
    ClientOrderBusinessController.invalidateBusinessSummary(businessUserId);
    ClientProductsController.invalidateBusinessSummary(businessUserId);
    ClientProductCardController.invalidateBusinessSummary(businessUserId);

    final summary = await _orderRepository.getBusinessSummaryForOrder(
      businessUserId,
    );
    ClientOrderBusinessController.cacheBusinessSummary(businessUserId, summary);
    ClientProductsController.cacheBusinessSummary(businessUserId, summary);
    ClientProductCardController.cacheBusinessSummary(businessUserId, summary);
  }
}
