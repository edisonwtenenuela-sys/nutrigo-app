import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/client/controllers/review_dialog_controller.dart';

export 'package:emprendedor/features/client/controllers/review_dialog_controller.dart'
    show ReviewDialogResult;

class ReviewDialog extends StatefulWidget {
  final String businessName;

  const ReviewDialog({super.key, required this.businessName});

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  late final ReviewDialogController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReviewDialogController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(_controller.buildResult());
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    const ratingColor = RoleTheme.iconRating;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 32.r,
                  backgroundColor: ratingColor.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.star_rounded,
                    color: ratingColor,
                    size: 38.sp,
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'Calificar emprendimiento',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  widget.businessName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 18.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    final isSelected = starValue <= _controller.rating;

                    return IconButton(
                      onPressed: () => _controller.updateRating(starValue),
                      icon: Icon(
                        isSelected
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: ratingColor,
                        size: 34.sp,
                      ),
                    );
                  }),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: _controller.commentController,
                  maxLines: 3,
                  maxLength: 160,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 12.8.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Escribe una reseña opcional...',
                    hintStyle: TextStyle(
                      color: palette.mutedText,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: palette.background,
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: ratingColor.withValues(alpha: 0.12),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: ratingColor.withValues(alpha: 0.12),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(
                        color: ratingColor,
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: RoleTheme.iconDanger,
                          backgroundColor: RoleTheme.iconDanger.withValues(
                            alpha: 0.05,
                          ),
                          side: BorderSide(
                            color: RoleTheme.iconDanger.withValues(alpha: 0.20),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 13.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: ratingColor.withValues(alpha: 0.05),
                          foregroundColor: ratingColor,
                          side: BorderSide(
                            color: ratingColor.withValues(alpha: 0.20),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 13.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          'Enviar',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
