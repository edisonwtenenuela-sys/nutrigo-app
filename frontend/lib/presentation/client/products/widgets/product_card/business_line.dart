import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/client/products/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BusinessLine extends StatelessWidget {
  final ProductCardBusinessInfo business;
  final bool isLoading;

  const BusinessLine({
    super.key,
    required this.business,
    required this.isLoading,
  });

  String _reviewsText(ProductCardBusinessInfo business) {
    if (business.totalReviews <= 0) return 'Sin reseñas';
    final label = business.totalReviews == 1 ? 'reseña' : 'reseñas';
    return '${business.rating.toStringAsFixed(1)} (${business.totalReviews}) $label';
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Row(
      children: [
        BusinessAvatar(imageUrl: business.imageUrl),
        SizedBox(width: 5.w),
        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: isLoading ? 'Cargando negocio' : business.name,
                  style: TextStyle(
                    color: isLoading ? palette.mutedText : palette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (!isLoading) ...[
                  TextSpan(
                    text: '  -  ',
                    style: TextStyle(
                      color: palette.mutedText.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      business.totalReviews > 0
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: RoleTheme.iconRating,
                      size: 10.5.sp,
                    ),
                  ),
                  TextSpan(
                    text: ' ${_reviewsText(business)}',
                    style: TextStyle(
                      color: palette.mutedText.withValues(alpha: 0.78),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10.sp, height: 1.1),
          ),
        ),
      ],
    );
  }
}
