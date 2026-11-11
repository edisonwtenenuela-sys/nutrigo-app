import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/client/nutritionist_review_model.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';
import 'package:emprendedor/data/repositories/client/nutritionist_review_repository.dart';

class NutritionistReviewsPage extends StatelessWidget {
  final NutritionistProfileModel profile;
  final NutritionistReviewRepository _repository =
      NutritionistReviewRepository();

  NutritionistReviewsPage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: StreamBuilder<List<NutritionistReviewModel>>(
          stream: _repository.watchNutritionistReviews(
            nutritionistUserId: profile.userId,
          ),
          builder: (context, snapshot) {
            final reviews = snapshot.data ?? const <NutritionistReviewModel>[];
            final average = _average(profile, reviews);
            final count = _count(profile, reviews);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(onBack: Navigator.of(context).pop),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 18.h),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _SummaryCard(average: average, count: count),
                      if (snapshot.hasError) ...[
                        SizedBox(height: 12.h),
                        const _StatusCard(
                          icon: Icons.error_outline_rounded,
                          iconColor: RoleTheme.iconDanger,
                          title: 'No se pudieron cargar las reseñas',
                          message: 'Revisa tu conexión e inténtalo nuevamente.',
                        ),
                      ] else if (reviews.isEmpty) ...[
                        SizedBox(height: 12.h),
                        const _StatusCard(
                          icon: Icons.star_rounded,
                          iconColor: RoleTheme.iconWarning,
                          title: 'Sin reseñas todavía',
                          message:
                              'Cuando tus pacientes te valoren, sus comentarios aparecerán aquí.',
                        ),
                      ] else ...[
                        SizedBox(height: 12.h),
                        ...reviews.map((review) => _ReviewCard(review: review)),
                      ],
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
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

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return SizedBox(
      height: 58.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 8.w,
            child: IconButton(
              tooltip: 'Volver',
              onPressed: onBack,
              icon: Icon(
                Icons.arrow_back_rounded,
                color: RoleTheme.iconColorFor(
                  Icons.arrow_back_rounded,
                  fallback: palette.text,
                ),
                size: 22.sp,
              ),
            ),
          ),
          Text(
            'Reseñas',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: palette.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double average;
  final int count;

  const _SummaryCard({required this.average, required this.count});

  String get _summaryText {
    if (count <= 0) return 'Sin reseñas';
    final label = count == 1 ? 'reseña' : 'reseñas';
    return '${average.toStringAsFixed(1)} ($count) $label';
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            palette.primary.withValues(alpha: 0.95),
            palette.primary.withValues(alpha: 0.74),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.22),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Icon(
              Icons.star_rounded,
              color: Colors.amber.shade300,
              size: 32.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Valoración de pacientes',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _summaryText,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.84),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final NutritionistReviewModel review;

  const _ReviewCard({required this.review});

  String get _clientName {
    final name = review.clientName.trim();
    return name.isEmpty ? 'Paciente' : name;
  }

  String get _comment {
    final value = review.comment?.trim() ?? '';
    return value.isEmpty ? 'Sin comentario.' : value;
  }

  String? get _imageUrl {
    final value = review.clientProfileImageUrl?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  String get _initials {
    final words = _clientName
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .toList();

    if (words.isEmpty) return 'P';
    if (words.length == 1) return words.first.characters.first.toUpperCase();
    return '${words.first.characters.first}${words.last.characters.first}'
        .toUpperCase();
  }

  String get _dateLabel {
    final date = review.createdAt.toDate().toLocal();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 16.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PatientAvatar(imageUrl: _imageUrl, initials: _initials),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _clientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: palette.text,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: RoleTheme.iconWarning,
                            size: 17.sp,
                          );
                        }),
                        SizedBox(width: 6.w),
                        Text(
                          '${review.rating}.0',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: palette.mutedText,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: palette.primary,
                      size: 12.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _dateLabel,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: palette.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: palette.background.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: palette.primary.withValues(alpha: 0.07),
              ),
            ),
            child: Text(
              _comment,
              style: TextStyle(
                fontSize: 12.5.sp,
                height: 1.38,
                color: palette.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientAvatar extends StatelessWidget {
  final String? imageUrl;
  final String initials;

  const _PatientAvatar({required this.imageUrl, required this.initials});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            palette.primary.withValues(alpha: 0.18),
            palette.accent.withValues(alpha: 0.14),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: palette.primary.withValues(alpha: 0.14)),
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _AvatarFallback(initials: initials);
                },
              )
            : _AvatarFallback(initials: initials),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String initials;

  const _AvatarFallback({required this.initials});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w900,
          color: palette.primary,
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;

  const _StatusCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 12.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              color: palette.text,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: palette.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}
