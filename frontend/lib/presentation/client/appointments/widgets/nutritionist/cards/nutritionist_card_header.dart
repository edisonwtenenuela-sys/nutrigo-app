import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/nutritionist/details/nutritionist_info_badge.dart';
import 'package:emprendedor/presentation/shared/widgets/smooth_profile_avatar.dart';

class NutritionistCardHeader extends StatelessWidget {
  final NutritionistProfileModel nutritionist;
  final bool isExpanded;

  const NutritionistCardHeader({
    super.key,
    required this.nutritionist,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    final imageUrl = nutritionist.profileImageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final avatarSize = isExpanded ? 58.r : 50.r;

    final ratingText = nutritionist.hasReviews
        ? '${nutritionist.averageRating.toStringAsFixed(1)} (${nutritionist.reviewsCount})'
        : null;

    final consultationColor =
    nutritionist.consultationMode ==
        NutritionistConsultationMode.presencial
        ? RoleTheme.iconLocation
        : RoleTheme.iconCommunication;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: RoleTheme.iconHealth.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: SmoothProfileAvatar(
            imageUrl: hasImage ? imageUrl : null,
            size: avatarSize,
            overlayColor: Colors.transparent,
            fallback: Container(
              color: palette.background,
              alignment: Alignment.center,
              child: Icon(
                Icons.person_rounded,
                color: RoleTheme.iconProfile,
                size: isExpanded ? 29.sp : 24.sp,
              ),
            ),
          ),
        ),
        SizedBox(width: 11.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nutritionist.name,
                maxLines: isExpanded ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.text,
                  fontSize: isExpanded ? 16.sp : 14.5.sp,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                nutritionist.specialty?.isNotEmpty == true
                    ? nutritionist.specialty!
                    : 'Nutrición profesional',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.mutedText,
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 7.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 5.h,
                children: [
                  NutritionistInfoBadge(
                    icon:
                    nutritionist.consultationMode ==
                        NutritionistConsultationMode.presencial
                        ? Icons.location_on_rounded
                        : Icons.video_call_rounded,
                    text: nutritionist.consultationMode.label,
                    color: consultationColor,
                  ),
                  if (nutritionist.isVerified)
                    const NutritionistInfoBadge(
                      icon: Icons.verified_rounded,
                      text: 'Verificado',
                      color: RoleTheme.iconValidation,
                    ),
                  if (ratingText != null)
                    NutritionistInfoBadge(
                      icon: Icons.star_rounded,
                      text: ratingText,
                      color: RoleTheme.iconRating,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}