import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/client/nutritionist_review_model.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';
import 'package:emprendedor/data/repositories/client/nutritionist_review_repository.dart';
import 'package:emprendedor/presentation/nutritionist/profile/pages/nutritionist_reviews_page.dart';

class NutritionistReviewsPreviewCard extends StatelessWidget {
  final NutritionistProfileModel? profile;
  final NutritionistReviewRepository _repository =
  NutritionistReviewRepository();

  NutritionistReviewsPreviewCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final currentProfile = profile;
    final userId = currentProfile?.userId.trim() ?? '';

    if (currentProfile == null || userId.isEmpty) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<NutritionistReviewModel>>(
      stream: _repository.watchNutritionistReviews(nutritionistUserId: userId),
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? const <NutritionistReviewModel>[];
        final average = _average(currentProfile, reviews);
        final count = _count(currentProfile, reviews);

        return _ReviewsSummaryCard(
          average: average,
          count: count,
          hasError: snapshot.hasError,
          onTap: () {
            AppNavigator.push(
              context,
              NutritionistReviewsPage(profile: currentProfile),
            );
          },
        );
      },
    );
  }

  static double _average(
      NutritionistProfileModel profile,
      List<NutritionistReviewModel> reviews,
      ) {
    if (profile.hasReviews) return profile.averageRating;
    if (reviews.isEmpty) return 0;

    final total = reviews.fold<int>(0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }

  static int _count(
      NutritionistProfileModel profile,
      List<NutritionistReviewModel> reviews,
      ) {
    if (profile.reviewsCount > 0) return profile.reviewsCount;
    return reviews.length;
  }
}

class _ReviewsSummaryCard extends StatelessWidget {
  final double average;
  final int count;
  final bool hasError;
  final VoidCallback onTap;

  const _ReviewsSummaryCard({
    required this.average,
    required this.count,
    required this.hasError,
    required this.onTap,
  });

  String get _summaryText {
    if (count <= 0) return 'Sin reseñas';
    final label = count == 1 ? 'reseña' : 'reseñas';
    return '${average.toStringAsFixed(1)} ($count) $label';
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 16.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: RoleTheme.iconWarning.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: RoleTheme.iconWarning,
                  size: 25.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reseñas de pacientes',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: palette.text,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: RoleTheme.iconWarning,
                          size: 15.sp,
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            _summaryText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: palette.mutedText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (hasError) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'No se pudieron actualizar las reseñas.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: RoleTheme.iconDanger,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ver todas',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w900,
                      color: palette.primary,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: RoleTheme.iconColorFor(
                      Icons.chevron_right_rounded,
                      fallback: palette.primary,
                    ),
                    size: 20.sp,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}