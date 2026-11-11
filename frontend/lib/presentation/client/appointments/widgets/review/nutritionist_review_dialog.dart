import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/features/client/controllers/nutritionist_review_dialog_controller.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/review/review_comment_field.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/review/review_stars_selector.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/review/review_submit_button.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class NutritionistReviewDialog extends StatefulWidget {
  final AppointmentModel appointment;

  const NutritionistReviewDialog({
    super.key,
    required this.appointment,
  });

  @override
  State<NutritionistReviewDialog> createState() =>
      _NutritionistReviewDialogState();
}

class _NutritionistReviewDialogState extends State<NutritionistReviewDialog> {
  late final NutritionistReviewDialogController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NutritionistReviewDialogController(
      appointment: widget.appointment,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await _controller.submit();

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      return;
    }

    showAppMessage(
      context,
      role: AppFeedbackRole.client,
      type: AppFeedbackType.error,
      title: 'No se pudo guardar',
      message: _controller.errorMessage ?? 'No se pudo guardar la valoración.',
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Dialog(
      insetPadding: EdgeInsets.all(22.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  color: RoleTheme.iconRating,
                  size: 46.sp,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Valorar nutricionista',
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.appointment.nutritionistName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 14.h),
                ReviewStarsSelector(
                  rating: _controller.rating,
                  onChanged: _controller.updateRating,
                ),
                SizedBox(height: 12.h),
                ReviewCommentField(controller: _controller.commentController),
                SizedBox(height: 16.h),
                ReviewSubmitButton(
                  isLoading: _controller.isLoading,
                  onPressed: _submit,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}