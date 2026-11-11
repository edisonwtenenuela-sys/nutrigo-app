import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';

class AppointmentReviewSummaryCard extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentReviewSummaryCard({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    final rating = (appointment.reviewRating ?? 0).clamp(1, 5);
    final comment = appointment.reviewComment?.trim();
    final ratingColor = RoleTheme.iconRating;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 11.h),
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: ratingColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: ratingColor.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: ratingColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(
              Icons.star_rounded,
              color: ratingColor,
              size: 19.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Valoración enviada',
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: ratingColor,
                        size: 15.sp,
                      );
                    }),
                    SizedBox(width: 6.w),
                    Text(
                      '$rating de 5',
                      style: TextStyle(
                        color: ratingColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                if (comment != null && comment.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    comment,
                    style: TextStyle(
                      color: palette.mutedText,
                      fontSize: 11.2.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}