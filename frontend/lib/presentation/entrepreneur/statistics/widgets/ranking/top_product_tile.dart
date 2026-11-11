import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/stats/stats_model.dart';

class TopProductTile extends StatelessWidget {
  final TopProductStat product;

  const TopProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final productName = product.productName.trim().isNotEmpty
        ? product.productName.trim()
        : 'Producto';

    final imageUrl = product.productImageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    final totalRevenue = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
      locale: 'es_ES',
    ).format(product.totalRevenue);

    return Container(
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(13.r),
            child: hasImage
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 56.w,
                    height: 56.w,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 120),
                    placeholder: (context, url) {
                      return _ProductImagePlaceholder(palette: palette);
                    },
                    errorWidget: (context, url, error) {
                      return _ProductImagePlaceholder(
                        palette: palette,
                        icon: Icons.fastfood_rounded,
                      );
                    },
                  )
                : _ProductImagePlaceholder(
                    palette: palette,
                    icon: Icons.fastfood_rounded,
                  ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 11.6.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.17,
                  ),
                ),
                SizedBox(height: 5.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: palette.secondary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Text(
                    '${product.quantitySold} vendidos',
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      color: palette.secondary,
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Ingresos',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 9.4.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  totalRevenue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RoleTheme.iconValidation,
                    fontSize: 12.2.sp,
                    fontWeight: FontWeight.w900,
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

class _ProductImagePlaceholder extends StatelessWidget {
  final RolePalette palette;
  final IconData? icon;

  const _ProductImagePlaceholder({required this.palette, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.w,
      height: 56.w,
      color: palette.surface.withValues(alpha: 0.72),
      child: Center(
        child: icon == null
            ? SizedBox(
                width: 15.w,
                height: 15.w,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: palette.primary.withValues(alpha: 0.65),
                ),
              )
            : Icon(icon, color: palette.primary, size: 23.sp),
      ),
    );
  }
}
