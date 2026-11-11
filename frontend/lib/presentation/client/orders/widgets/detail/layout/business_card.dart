import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

import 'order_detail_business_info.dart';

class BusinessCard extends StatelessWidget {
  final OrderDetailBusinessInfo business;

  const BusinessCard({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final hasImage =
        business.imageUrl != null && business.imageUrl!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(9.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: RoleTheme.brandBorder.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: RoleTheme.brandSurfaceTint.withValues(alpha: 0.30),
              borderRadius: BorderRadius.circular(14.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasImage
                ? CachedNetworkImage(
                    imageUrl: business.imageUrl!,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 120),
                    memCacheWidth: 220,
                    memCacheHeight: 220,
                    placeholder: (context, url) => const SizedBox.shrink(),
                    errorWidget: (context, url, error) =>
                        const _BusinessPlaceholderIcon(),
                  )
                : const _BusinessPlaceholderIcon(),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  business.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Comidas saludables',
                  style: TextStyle(
                    color: RoleTheme.iconHealth,
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(
                      business.totalReviews > 0
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: RoleTheme.iconRating,
                      size: 14.sp,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        business.totalReviews > 0
                            ? '${business.rating.toStringAsFixed(1)} (${business.totalReviews}) ${business.totalReviews == 1 ? 'reseña' : 'reseñas'}'
                            : 'sin reseñas',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.mutedText,
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w600,
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

class _BusinessPlaceholderIcon extends StatelessWidget {
  const _BusinessPlaceholderIcon();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.storefront_rounded,
      color: RoleTheme.iconColorFor(
        Icons.storefront_rounded,
        fallback: RoleTheme.iconInfo,
      ),
      size: 20.sp,
    );
  }
}
