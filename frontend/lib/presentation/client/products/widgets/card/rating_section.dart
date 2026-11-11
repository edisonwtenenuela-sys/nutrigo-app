import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class RatingSection extends StatelessWidget {
  final double rating;
  final int totalReviews;

  const RatingSection({
    super.key,
    required this.rating,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    final hasReviews = totalReviews > 0;

    final textColor = hasReviews
        ? RoleTheme.brandMutedText
        : RoleTheme.brandMutedText.withValues(alpha: 0.72);

    final reviewLabel = totalReviews == 1 ? 'reseña' : 'reseñas';

    final label = hasReviews
        ? '${rating.toStringAsFixed(1)} ($totalReviews) $reviewLabel'
        : 'Sin reseñas';

    return Row(
      children: [
        Icon(
          hasReviews ? Icons.star_rounded : Icons.star_border_rounded,
          color: Colors.amber.shade600,
          size: 17.sp,
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}
