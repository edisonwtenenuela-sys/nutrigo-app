import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';
import 'package:emprendedor/data/models/shared/order_business_summary.dart';
import 'package:emprendedor/features/client/controllers/client_product_card_controller.dart';
import 'package:emprendedor/presentation/client/products/widgets/index.dart';

class ProductDetailHeroBlock extends StatelessWidget {
  final ProductModel product;
  final OrderBusinessSummary? initialBusinessSummary;

  const ProductDetailHeroBlock({
    super.key,
    required this.product,
    this.initialBusinessSummary,
  });

  static final ClientProductCardController _businessController =
      ClientProductCardController();

  Widget _buildImage(RolePalette palette) {
    final imageUrl = product.imageUrl?.trim();

    return Container(
      width: 110.w,
      height: 110.w,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19.r),
        child: Container(
          color: RoleTheme.brandSurfaceTint,
          child: imageUrl == null || imageUrl.isEmpty
              ? Icon(
                  Icons.restaurant_menu_rounded,
                  color: RoleTheme.iconColorFor(
                    Icons.restaurant_menu_rounded,
                    fallback: palette.primary,
                  ),
                  size: 42.sp,
                )
              : CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  placeholder: (context, url) =>
                      Container(color: RoleTheme.brandSurfaceTint),
                  errorWidget: (context, url, error) => Icon(
                    Icons.restaurant_menu_rounded,
                    color: RoleTheme.iconColorFor(
                      Icons.restaurant_menu_rounded,
                      fallback: palette.primary,
                    ),
                    size: 42.sp,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required RolePalette palette,
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
            size: 13.5.sp,
          ),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.text,
                fontSize: 9.8.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  OrderBusinessSummary? _cachedBusinessSummary() {
    final businessId = product.userId?.trim();
    if (businessId == null || businessId.isEmpty) return null;
    return initialBusinessSummary ??
        ClientProductCardController.cachedBusinessSummary(businessId);
  }

  Stream<OrderBusinessSummary?> _watchBusinessSummary() {
    return _businessController.watchBusinessSummaryForProduct(product);
  }

  String _reviewsText(OrderBusinessSummary summary) {
    if (summary.totalReviews <= 0) return '0 reseñas';
    final label = summary.totalReviews == 1 ? 'reseña' : 'reseñas';
    return '${summary.rating.toStringAsFixed(1)} (${summary.totalReviews}) $label';
  }

  Widget _buildBusinessLink(BuildContext context, RolePalette palette) {
    return StreamBuilder<OrderBusinessSummary?>(
      stream: _watchBusinessSummary(),
      initialData: _cachedBusinessSummary(),
      builder: (context, snapshot) {
        final summary = snapshot.data;
        final rawName = summary?.name.trim() ?? '';
        final isGeneric = ClientProductCardController.isGenericBusinessName(
          rawName,
        );
        final isLoading =
            snapshot.connectionState == ConnectionState.waiting &&
            summary == null;
        final businessName = rawName.isEmpty || isGeneric
            ? 'Negocio verificado'
            : rawName;
        final reviewsText = summary == null
            ? '0 reseñas'
            : _reviewsText(summary);

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: RoleTheme.brandSurfaceTint,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: RoleTheme.brandBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BusinessAvatar(imageUrl: summary?.imageUrl, size: 28),
              SizedBox(width: 8.w),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoading ? 'Cargando negocio' : businessName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 10.4.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.12,
                      ),
                    ),
                    if (!isLoading || summary != null) ...[
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            summary != null && summary.totalReviews > 0
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.amber.shade600,
                            size: 9.5.sp,
                          ),
                          SizedBox(width: 2.w),
                          Flexible(
                            child: Text(
                              reviewsText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.mutedText.withValues(
                                  alpha: 0.78,
                                ),
                                fontSize: 8.8.sp,
                                fontWeight: FontWeight.w500,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final calories = product.approxCalories == null
        ? null
        : '${product.approxCalories!.toStringAsFixed(0)} kcal';
    final ingredientsLabel = '${product.ingredients.length} ingredientes';

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildImage(palette),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 18.5.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                      ),
                    ),
                    if (product.isFeatured) ...[
                      SizedBox(height: 7.h),
                      const ProductTopChip(),
                    ],
                    SizedBox(height: 7.h),
                    _buildBusinessLink(context, palette),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 7.h),
            decoration: BoxDecoration(
              color: RoleTheme.brandSurfaceTint,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: RoleTheme.brandBorder),
            ),
            child: Row(
              children: [
                _buildQuickStat(
                  icon: Icons.local_fire_department_rounded,
                  label: calories ?? 'N/D kcal',
                  palette: palette,
                ),
                const _DividerLine(),
                _buildQuickStat(
                  icon: Icons.format_list_bulleted_rounded,
                  label: ingredientsLabel,
                  palette: palette,
                ),
                const _DividerLine(),
                _buildQuickStat(
                  icon: Icons.verified_rounded,
                  label:
                      product.validationStatus ==
                          NutritionValidationStatus.approved
                      ? 'Validado'
                      : 'En revisión',
                  palette: palette,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 17.h, color: RoleTheme.brandBorder);
  }
}
