import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';

class ProductSelectionTile extends StatelessWidget {
  final ProductModel product;
  final bool isSelected;
  final VoidCallback onTap;

  const ProductSelectionTile({
    super.key,
    required this.product,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final imageUrl = product.imageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final productName = product.name.trim().isNotEmpty
        ? product.name.trim()
        : 'Producto';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: isSelected
              ? palette.primary.withValues(alpha: 0.08)
              : palette.primary.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: isSelected
                ? palette.primary.withValues(alpha: 0.35)
                : palette.primary.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 42.w,
                      height: 42.w,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 120),
                      placeholder: (context, url) =>
                          const _ProductSelectionImagePlaceholder(),
                      errorWidget: (context, url, error) =>
                          const _ProductSelectionImagePlaceholder(
                            showIcon: true,
                          ),
                    )
                  : const _ProductSelectionImagePlaceholder(showIcon: true),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.text,
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.primary,
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            Checkbox(
              value: isSelected,
              onChanged: (_) => onTap(),
              activeColor: palette.primary,
              checkColor: palette.surface,
              side: BorderSide(
                color: isSelected
                    ? palette.primary
                    : palette.primary.withValues(alpha: 0.35),
                width: 1.2.w,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductSelectionImagePlaceholder extends StatelessWidget {
  final bool showIcon;

  const _ProductSelectionImagePlaceholder({this.showIcon = false});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      width: 42.w,
      height: 42.w,
      color: palette.primary.withValues(alpha: 0.045),
      child: Center(
        child: showIcon
            ? Icon(
                Icons.fastfood_rounded,
                color: RoleTheme.iconColorFor(
                  Icons.fastfood_rounded,
                  fallback: palette.primary,
                ),
                size: 21.sp,
              )
            : SizedBox(
                width: 14.w,
                height: 14.w,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: palette.primary.withValues(alpha: 0.55),
                ),
              ),
      ),
    );
  }
}
