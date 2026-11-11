import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/features/client/controllers/business_review_button_controller.dart';
import 'package:emprendedor/presentation/client/orders/widgets/index.dart';
import 'package:emprendedor/presentation/client/products/dialogs/review_dialog.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class ReviewButton extends StatefulWidget {
  final OrderModel order;
  final OrderDetailBusinessInfo business;

  const ReviewButton({super.key, required this.order, required this.business});

  @override
  State<ReviewButton> createState() => _ReviewButtonState();
}

class _ReviewButtonState extends State<ReviewButton> {
  late final BusinessReviewButtonController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BusinessReviewButtonController(order: widget.order);
    _controller.loadReviewState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openReviewDialog() async {
    if (_controller.isSubmitting) return;

    final result = await showDialog<ReviewDialogResult>(
      context: context,
      builder: (_) => ReviewDialog(businessName: widget.business.name),
    );

    if (result == null) return;

    final success = await _controller.submitReview(
      rating: result.rating,
      comment: result.comment,
    );

    if (!mounted) return;

    if (success) {
      showAppMessage(
        context,
        role: AppFeedbackRole.client,
        type: AppFeedbackType.success,
        title: 'Valoración enviada',
        message: 'Gracias por valorar tu experiencia.',
      );
      return;
    }

    showAppMessage(
      context,
      role: AppFeedbackRole.client,
      type: AppFeedbackType.error,
      title: 'No se pudo guardar',
      message: _controller.errorMessage ?? 'No se pudo guardar la reseña.',
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final ratingColor = RoleTheme.iconColorFor(
      Icons.star_rounded,
      fallback: RoleTheme.iconRating,
    );
    final successColor = RoleTheme.iconColorFor(
      Icons.check_circle_rounded,
      fallback: RoleTheme.iconValidation,
    );

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const SizedBox.shrink();
        }

        if (_controller.hasReviewed) {
          return Container(
            width: double.infinity,
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: successColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: successColor.withValues(alpha: 0.16)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: successColor,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Gracias por valorar tu experiencia.',
                    style: TextStyle(
                      color: palette.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton.icon(
            onPressed: _controller.isSubmitting ? null : _openReviewDialog,
            icon: _controller.isSubmitting
                ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ratingColor,
                    ),
                  )
                : Icon(Icons.star_rounded, color: ratingColor, size: 20.sp),
            label: Text(
              _controller.isSubmitting
                  ? 'Guardando reseña...'
                  : 'Valorar experiencia',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.sp),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shadowColor: Colors.transparent,
              backgroundColor: ratingColor.withValues(alpha: 0.07),
              foregroundColor: ratingColor,
              disabledBackgroundColor: ratingColor.withValues(alpha: 0.04),
              disabledForegroundColor: ratingColor.withValues(alpha: 0.45),
              side: BorderSide(color: ratingColor.withValues(alpha: 0.20)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
        );
      },
    );
  }
}
