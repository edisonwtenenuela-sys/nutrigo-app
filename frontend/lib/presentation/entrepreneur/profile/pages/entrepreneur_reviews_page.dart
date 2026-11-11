import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/client/business_review_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';
import 'package:emprendedor/presentation/shared/widgets/smooth_profile_avatar.dart';

class BusinessReviewsPage extends StatefulWidget {
  const BusinessReviewsPage({super.key, required this.businessUserId});

  final String businessUserId;

  @override
  State<BusinessReviewsPage> createState() => _BusinessReviewsPageState();
}

class _BusinessReviewsPageState extends State<BusinessReviewsPage> {
  final BusinessReviewsController _reviewsController =
      BusinessReviewsController();
  _ReviewsSort _selectedSort = _ReviewsSort.recent;
  late Stream<List<BusinessReviewModel>> _reviewsStream;

  @override
  void initState() {
    super.initState();
    _reviewsStream = _reviewsController.watchReviews(widget.businessUserId);
  }

  @override
  void didUpdateWidget(covariant BusinessReviewsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.businessUserId == widget.businessUserId) return;
    _reviewsStream = _reviewsController.watchReviews(widget.businessUserId);
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Reseñas',
          style: TextStyle(
            color: palette.text,
            fontSize: 19.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: StreamBuilder<List<BusinessReviewModel>>(
        stream: _reviewsStream,
        initialData: _reviewsController.cachedReviews(widget.businessUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: RoleTheme.iconRating),
            );
          }

          final reviews = snapshot.data ?? [];
          final sortedReviews = _sortReviews(reviews);

          if (!_reviewsController.hasReviews(reviews)) {
            return const _ReviewsEmptyState();
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
            itemCount: sortedReviews.length + 1,
            itemBuilder: (_, index) {
              if (index == 0) {
                return Column(
                  children: [
                    _ReviewsHeader(
                      average: _reviewsController.averageRating(reviews),
                      count: reviews.length,
                    ),
                    _ReviewsSortBar(
                      selectedSort: _selectedSort,
                      onChanged: (sort) {
                        if (sort == _selectedSort) return;
                        setState(() => _selectedSort = sort);
                      },
                    ),
                  ],
                );
              }

              final review = sortedReviews[index - 1];
              return _ReviewCard(
                key: ValueKey(_reviewKey(review)),
                review: review,
                clientName: _reviewsController.clientNameText(review),
                commentText: _reviewsController.commentText(review),
                imageUrl: review.clientProfileImageUrl,
              );
            },
          );
        },
      ),
    );
  }

  List<BusinessReviewModel> _sortReviews(List<BusinessReviewModel> reviews) {
    final sorted = [...reviews];

    sorted.sort((a, b) {
      return switch (_selectedSort) {
        _ReviewsSort.recent => _dateValue(b).compareTo(_dateValue(a)),
        _ReviewsSort.highest => b.rating.compareTo(a.rating),
        _ReviewsSort.lowest => a.rating.compareTo(b.rating),
      };
    });

    return sorted;
  }

  int _dateValue(BusinessReviewModel review) {
    return review.createdAt?.millisecondsSinceEpoch ?? 0;
  }

  String _reviewKey(BusinessReviewModel review) {
    final id = review.id?.trim();
    if (id != null && id.isNotEmpty) return id;
    return '${review.orderId}-${review.clientUserId}-${_dateValue(review)}';
  }
}

enum _ReviewsSort {
  recent,
  highest,
  lowest;

  String get label {
    return switch (this) {
      _ReviewsSort.recent => 'Recientes',
      _ReviewsSort.highest => 'Mejor calificadas',
      _ReviewsSort.lowest => 'Menor calificación',
    };
  }

  IconData get icon {
    return switch (this) {
      _ReviewsSort.recent => Icons.schedule_rounded,
      _ReviewsSort.highest => Icons.star_rounded,
      _ReviewsSort.lowest => Icons.trending_down_rounded,
    };
  }
}

class _ReviewsSortBar extends StatelessWidget {
  const _ReviewsSortBar({required this.selectedSort, required this.onChanged});

  final _ReviewsSort selectedSort;
  final ValueChanged<_ReviewsSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 12.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _ReviewsSort.values.map((sort) {
            final selected = selectedSort == sort;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: _ReviewsSortChip(
                sort: sort,
                selected: selected,
                onTap: () => onChanged(sort),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ReviewsSortChip extends StatelessWidget {
  const _ReviewsSortChip({
    required this.sort,
    required this.selected,
    required this.onTap,
  });

  final _ReviewsSort sort;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;
    final selectedForeground = Color.lerp(
      RoleTheme.iconRating,
      palette.text,
      0.18,
    )!;
    final foreground = selected ? selectedForeground : palette.text;
    final iconColor = RoleTheme.iconRating;
    final background = selected
        ? RoleTheme.iconRating.withValues(alpha: 0.18)
        : RoleTheme.iconRating.withValues(alpha: 0.07);
    final borderColor = selected
        ? RoleTheme.iconRating.withValues(alpha: 0.46)
        : RoleTheme.iconRating.withValues(alpha: 0.18);

    return InkWell(
      borderRadius: BorderRadius.circular(999.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: borderColor),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: RoleTheme.iconRating.withValues(alpha: 0.08),
                    blurRadius: 8.r,
                    offset: Offset(0, 3.h),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(sort.icon, size: 13.sp, color: iconColor),
            SizedBox(width: 5.w),
            Text(
              sort.label,
              style: TextStyle(
                color: foreground,
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewsHeader extends StatelessWidget {
  const _ReviewsHeader({required this.average, required this.count});

  final double average;
  final int count;

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            RoleTheme.iconRating.withValues(alpha: 0.15),
            palette.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: RoleTheme.iconRating.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: RoleTheme.iconRating.withValues(alpha: 0.06),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.reviews_rounded,
              color: RoleTheme.iconRating,
              size: 25.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Opiniones de clientes',
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      average.toStringAsFixed(1),
                      style: TextStyle(
                        color: RoleTheme.iconRating,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.star_rounded,
                      color: RoleTheme.iconRating,
                      size: 16.sp,
                    ),
                    SizedBox(width: 7.w),
                    Expanded(
                      child: Text(
                        '$count ${count == 1 ? 'reseña registrada' : 'reseñas registradas'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.mutedText,
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
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
  const _ReviewCard({
    super.key,
    required this.review,
    required this.clientName,
    required this.commentText,
    required this.imageUrl,
  });

  final BusinessReviewModel review;
  final String clientName;
  final String commentText;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;
    final createdAt = review.createdAt?.toDate();
    final initial = clientName.trim().isEmpty
        ? 'C'
        : clientName.trim().characters.first.toUpperCase();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.fromLTRB(13.w, 13.h, 13.w, 14.h),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: RoleTheme.iconRating.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmoothProfileAvatar(
                imageUrl: imageUrl,
                size: 36.r,
                overlayColor: Colors.transparent,
                loadingIndicator: const SizedBox.shrink(),
                fallback: Container(
                  color: RoleTheme.iconRating.withValues(alpha: 0.14),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: RoleTheme.iconRating,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.4.sp,
                        color: palette.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        ...List.generate(5, (starIndex) {
                          return Icon(
                            starIndex < review.rating.round()
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: RoleTheme.iconRating,
                            size: 15.sp,
                          );
                        }),
                        SizedBox(width: 6.w),
                        Text(
                          review.rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: palette.mutedText,
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (createdAt != null)
                Text(
                  _formatDate(createdAt),
                  style: TextStyle(
                    color: palette.mutedText.withValues(alpha: 0.72),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          SizedBox(height: 11.h),
          Text(
            commentText,
            style: TextStyle(
              fontSize: 12.5.sp,
              height: 1.35,
              color: palette.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}

class _ReviewsEmptyState extends StatelessWidget {
  const _ReviewsEmptyState();

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(22.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(24.w, 30.h, 24.w, 32.h),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: RoleTheme.iconRating.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star_border_rounded,
                color: RoleTheme.iconRating,
                size: 42.sp,
              ),
              SizedBox(height: 12.h),
              Text(
                'Aún no tienes reseñas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Cuando tus clientes valoren sus pedidos, sus opiniones aparecerán aquí.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.mutedText,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
