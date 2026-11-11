import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/core/utils/product_category_display.dart';
import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';
import 'package:emprendedor/presentation/nutritionist/products/widgets/card/nutritionist_product_info_chip.dart';
import 'package:emprendedor/presentation/nutritionist/products/widgets/status/nutritionist_product_status_badge.dart';

class NutritionistProductValidationCard extends StatelessWidget {
  final ProductModel product;
  final bool isProcessing;
  final bool isLoading;
  final VoidCallback onReview;

  const NutritionistProductValidationCard({
    super.key,
    required this.product,
    required this.isProcessing,
    required this.isLoading,
    required this.onReview,
  });

  String _productName() {
    final name = product.name.trim();
    return name.isEmpty ? 'Producto sin nombre' : name;
  }

  String _productDescription() {
    final description = product.description.trim();
    return description.isEmpty ? 'Sin descripción.' : description;
  }

  List<Widget> _buildInfoChips() {
    return [
      if (product.servingSize?.trim().isNotEmpty == true)
        NutritionistProductInfoChip(
          icon: Icons.scale_rounded,
          label: product.servingSize!.trim(),
          color: RoleTheme.nutritionist.primary,
        ),
      if (product.approxCalories != null)
        NutritionistProductInfoChip(
          icon: Icons.local_fire_department_rounded,
          label: '${product.approxCalories!.toStringAsFixed(0)} kcal',
          color: RoleTheme.iconWarning,
        ),
      if (product.category.trim().isNotEmpty)
        NutritionistProductInfoChip(
          icon: Icons.category_rounded,
          label: ProductCategoryDisplay.label(product.category),
          color: RoleTheme.iconInfo,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    final isDisabled = isLoading || isProcessing;
    final reviewLabel =
    product.validationStatus == NutritionValidationStatus.pending
        ? 'Revisar'
        : 'Ver detalle';

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: isProcessing ? 0.45 : 1,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: palette.primary.withValues(alpha: 0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              blurRadius: 14.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.r),
                  child: Container(
                    width: 72.w,
                    height: 72.w,
                    color: palette.background,
                    child: product.imageUrl?.trim().isNotEmpty == true
                        ? CachedNetworkImage(
                      imageUrl: product.imageUrl!.trim(),
                      fit: BoxFit.cover,
                      fadeInDuration:
                      const Duration(milliseconds: 300),
                      fadeOutDuration:
                      const Duration(milliseconds: 120),
                      placeholder: (_, _) => _ProductImageLoading(
                        palette: palette,
                      ),
                      errorWidget: (_, _, _) =>
                      const _ProductImageFallback(),
                    )
                        : const _ProductImageFallback(),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          NutritionistProductStatusBadge(
                            status: product.validationStatus,
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: isDisabled ? null : onReview,
                            icon: Icon(
                              Icons.visibility_rounded,
                              color: RoleTheme.iconColorFor(
                                Icons.visibility_rounded,
                                fallback: palette.primary,
                              ),
                              size: 14.sp,
                            ),
                            label: Text(
                              reviewLabel,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: palette.primary,
                              disabledForegroundColor:
                              palette.mutedText.withValues(alpha: 0.55),
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 7.h),
                      Text(
                        _productName(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                          color: palette.text,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _productDescription(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: palette.mutedText,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 9.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: _buildInfoChips(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImageLoading extends StatelessWidget {
  final RolePalette palette;

  const _ProductImageLoading({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 18.w,
        height: 18.w,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: palette.primary,
        ),
      ),
    );
  }
}

class _ProductImageFallback extends StatelessWidget {
  const _ProductImageFallback();

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Center(
      child: Icon(
        Icons.fastfood_rounded,
        color: RoleTheme.iconColorFor(
          Icons.fastfood_rounded,
          fallback: palette.primary,
        ),
        size: 28.sp,
      ),
    );
  }
}