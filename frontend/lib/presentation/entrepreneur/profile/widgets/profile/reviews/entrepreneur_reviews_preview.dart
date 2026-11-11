import 'dart:async';

import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/client/business_review_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/business_reviews_controller.dart';
import 'package:emprendedor/presentation/entrepreneur/profile/pages/index.dart';
import 'package:emprendedor/presentation/shared/widgets/smooth_profile_avatar.dart';

class BusinessReviewsPreview extends StatefulWidget {
  final String businessUserId;

  const BusinessReviewsPreview({super.key, required this.businessUserId});

  @override
  State<BusinessReviewsPreview> createState() => _BusinessReviewsPreviewState();
}

class _BusinessReviewsPreviewState extends State<BusinessReviewsPreview> {
  final BusinessReviewsController _controller = BusinessReviewsController();
  bool _allowEmptyState = false;
  Timer? _emptyStateTimer;
  List<BusinessReviewModel>? _lastReviews;

  @override
  void initState() {
    super.initState();
    _lastReviews = _controller.cachedReviews(widget.businessUserId);
    _emptyStateTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() => _allowEmptyState = true);
    });
  }

  @override
  void didUpdateWidget(covariant BusinessReviewsPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.businessUserId == widget.businessUserId) return;

    _allowEmptyState = false;
    _lastReviews = _controller.cachedReviews(widget.businessUserId);
    _emptyStateTimer?.cancel();
    _emptyStateTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() => _allowEmptyState = true);
    });
  }

  @override
  void dispose() {
    _emptyStateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.businessUserId.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<BusinessReviewModel>>(
      stream: _controller.watchReviews(widget.businessUserId, limit: 12),
      initialData: _lastReviews,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const _ReviewsLoadingCard();
        }

        final incomingReviews = snapshot.data ?? [];
        if (incomingReviews.isNotEmpty) {
          _lastReviews = incomingReviews;
        }
        final reviews = incomingReviews.isNotEmpty
            ? incomingReviews
            : _lastReviews ?? <BusinessReviewModel>[];

        if (reviews.isEmpty) {
          if (!_allowEmptyState) return const _ReviewsLoadingCard();
          return const _ReviewsEmptyCard();
        }

        final previewReviews = _controller.uniqueRecentReviewsByClient(
          reviews,
          limit: 3,
        );
        final average = _controller.averageRating(reviews);

        return _ReviewsCard(
          average: average,
          count: previewReviews.length,
          businessUserId: widget.businessUserId,
          children: previewReviews.map((review) {
            return _ReviewItem(
              rating: review.rating,
              clientName: _controller.clientNameText(review),
              comment: _controller.commentText(review),
              imageUrl: review.clientProfileImageUrl,
            );
          }).toList(),
        );
      },
    );
  }
}

class _ReviewsCard extends StatelessWidget {
  final double average;
  final int count;
  final String businessUserId;
  final List<Widget> children;

  const _ReviewsCard({
    required this.average,
    required this.count,
    required this.businessUserId,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 16.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(13.r),
                ),
                child: Icon(
                  Icons.reviews_rounded,
                  color: Colors.amber.shade800,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reseñas de clientes',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: palette.text,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Text(
                          average.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 11.3.sp,
                            color: palette.mutedText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber.shade600,
                          size: 13.sp,
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            '- $count ${count == 1 ? 'cliente reciente' : 'clientes recientes'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.3.sp,
                              color: palette.mutedText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  AppNavigator.push(
                    context,
                    BusinessReviewsPage(businessUserId: businessUserId),
                  );
                },
                child: Text(
                  'Ver todas',
                  style: TextStyle(
                    color: palette.primary,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final double rating;
  final String clientName;
  final String comment;
  final String? imageUrl;

  const _ReviewItem({
    required this.rating,
    required this.clientName,
    required this.comment,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;
    final initial = clientName.trim().isEmpty
        ? 'C'
        : clientName.trim().characters.first.toUpperCase();

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SmoothProfileAvatar(
                imageUrl: imageUrl,
                size: 28.r,
                overlayColor: Colors.transparent,
                loadingIndicator: const SizedBox.shrink(),
                fallback: Container(
                  color: RoleTheme.iconRating.withValues(alpha: 0.14),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: RoleTheme.iconRating,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  clientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: palette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ...List.generate(5, (index) {
                return Icon(
                  index < rating.round()
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: Colors.amber.shade600,
                  size: 14.sp,
                );
              }),
            ],
          ),
          SizedBox(height: 7.h),
          Text(
            comment,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.35,
              color: palette.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsLoadingCard extends StatelessWidget {
  const _ReviewsLoadingCard();

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(
              Icons.star_border_rounded,
              color: Colors.amber.shade800,
              size: 23.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Aún no tienes reseñas de clientes.',
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w800,
                color: palette.mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsEmptyCard extends StatelessWidget {
  const _ReviewsEmptyCard();

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(
              Icons.star_border_rounded,
              color: Colors.amber.shade800,
              size: 23.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Aún no tienes reseñas de clientes.',
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w800,
                color: palette.mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
