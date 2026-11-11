import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/core/utils/product_category_display.dart';
import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';
import 'package:emprendedor/data/models/shared/order_business_summary.dart';
import 'package:emprendedor/features/client/controllers/client_product_card_controller.dart';
import 'package:emprendedor/features/client/controllers/client_product_promotion_controller.dart';
import 'package:emprendedor/features/client/controllers/client_products_controller.dart';
import 'package:emprendedor/presentation/client/products/pages/index.dart';
import 'package:emprendedor/presentation/client/products/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final OrderBusinessSummary? businessSummary;
  final ProductPromotionInfo? promotionInfo;
  final bool promotionResolved;
  final bool resolveBusinessIndependently;
  final bool resolvePromotionIndependently;

  ProductCard({
    super.key,
    required this.product,
    this.businessSummary,
    this.promotionInfo,
    this.promotionResolved = false,
    this.resolveBusinessIndependently = true,
    this.resolvePromotionIndependently = true,
  });

  final ClientProductCardController _controller = ClientProductCardController();

  static const ProductCardBusinessInfo _defaultBusiness =
      ProductCardBusinessInfo(
        name: '',
        imageUrl: null,
        rating: 0,
        totalReviews: 0,
        openingHours: null,
        description: null,
      );

  Future<ProductCardBusinessInfo> _getBusinessInfo() async {
    final summary = await _controller.getBusinessSummaryForProduct(product);
    if (summary == null) return _defaultBusiness;

    return _businessInfoFromSummary(summary);
  }

  ProductCardBusinessInfo _resolveInitialBusinessInfo() {
    final summary = businessSummary;
    if (summary == null) return _defaultBusiness;
    return _businessInfoFromSummary(summary);
  }

  ProductCardBusinessInfo _businessInfoFromSummary(
    OrderBusinessSummary summary,
  ) {
    return ProductCardBusinessInfo(
      name: _visibleBusinessName(summary.name),
      imageUrl: summary.imageUrl,
      rating: summary.rating,
      totalReviews: summary.totalReviews,
      openingHours: summary.openingHours,
      description: summary.description,
    );
  }

  String _visibleBusinessName(String name) {
    final normalizedName = name.trim();
    return ClientProductCardController.isGenericBusinessName(normalizedName)
        ? ''
        : normalizedName;
  }

  void _openBusinessStore(
    BuildContext context,
    ProductCardBusinessInfo business,
    ProductPromotionInfo? promotionInfo,
    bool promotionResolved,
  ) {
    final businessId = product.userId?.trim();
    if (businessId == null || businessId.isEmpty) {
      AppNavigator.push(
        context,
        ProductDetailPage(
          product: product,
          initialPromotion: promotionInfo,
          promotionResolved: promotionResolved,
          initialBusinessSummary: business.name.trim().isEmpty
              ? null
              : OrderBusinessSummary(
                  name: business.name,
                  imageUrl: business.imageUrl,
                  rating: business.rating,
                  totalReviews: business.totalReviews,
                  openingHours: business.openingHours,
                  description: business.description,
                ),
        ),
      );
      return;
    }

    final initialSummary = business.name.trim().isEmpty
        ? null
        : OrderBusinessSummary(
            name: business.name,
            imageUrl: business.imageUrl,
            rating: business.rating,
            totalReviews: business.totalReviews,
            openingHours: business.openingHours,
            description: business.description,
          );

    final initialProducts =
        ClientProductsController.cachedApprovedProductsForBusiness(businessId);

    AppNavigator.push(
      context,
      BusinessStorePage(
        businessId: businessId,
        initialSummary: initialSummary,
        initialProducts: initialProducts,
        initialPromotions: ClientProductsController.cachedPromotionsForProducts(
          initialProducts,
        ),
        highlightedProduct: product,
        highlightedPromotion: promotionInfo,
        highlightedPromotionResolved: promotionResolved,
      ),
    );
  }

  Widget _buildCardContent({
    required BuildContext context,
    required ProductCardBusinessInfo business,
    required ProductPromotionInfo? promoInfo,
    required bool isPromotionLoading,
  }) {
    const palette = RoleTheme.client;
    final businessName = business.name.trim();
    final isBusinessLoading = businessName.isEmpty;
    final promo = promoInfo;

    final canApplyDiscount =
        promo?.isDiscountAvailableFor(product.price) ?? false;
    final finalPrice = canApplyDiscount
        ? promo!.finalPrice(product.price)
        : product.price;
    final discount = canApplyDiscount ? promo!.discountFor(product.price) : 0.0;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => _openBusinessStore(
            context,
            business,
            promoInfo,
            !isPromotionLoading,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(10.w, 10.h, 9.w, 10.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: RoleTheme.iconHealth.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: RoleTheme.iconHealth.withValues(alpha: 0.035),
                        blurRadius: 12.r,
                        offset: Offset(0, 5.h),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          ProductImage(imageUrl: product.imageUrl, size: 88),
                          if (product.isFeatured) const ProductTopImageBadge(),
                        ],
                      ),
                      SizedBox(width: 11.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: palette.text,
                                      fontSize: 13.2.sp,
                                      fontWeight: FontWeight.w900,
                                      height: 1.08,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 7.w),
                                PriceLabel(
                                  isLoading: isPromotionLoading,
                                  currentPrice: finalPrice,
                                  originalPrice:
                                      canApplyDiscount && discount > 0
                                      ? product.price
                                      : null,
                                ),
                              ],
                            ),
                            SizedBox(height: 5.h),
                            Wrap(
                              spacing: 5.w,
                              runSpacing: 3.h,
                              children: [
                                const ProductCardValidatedBadge(),
                                CategoryChip(
                                  label: ProductCategoryDisplay.label(
                                    product.category,
                                  ),
                                ),
                                if (isPromotionLoading)
                                  const PromoChipSkeleton()
                                else if (promo != null)
                                  PromoChip(label: promo.availabilityLabel),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            BusinessLine(
                              business: business,
                              isLoading: isBusinessLoading,
                            ),
                            SizedBox(height: 7.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 11.w,
                                    runSpacing: 3.h,
                                    children: [
                                      MetaText(
                                        icon: Icons
                                            .local_fire_department_outlined,
                                        label: product.approxCalories == null
                                            ? 'Sin kcal'
                                            : '${product.approxCalories!.toStringAsFixed(0)} kcal',
                                      ),
                                      MetaText(
                                        icon:
                                            Icons.format_list_bulleted_rounded,
                                        label:
                                            '${product.ingredients.length} ingredientes',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialBusiness = _resolveInitialBusinessInfo();

    if (!resolveBusinessIndependently || initialBusiness.name.isNotEmpty) {
      return _buildWithBusiness(context, initialBusiness);
    }

    return FutureBuilder<ProductCardBusinessInfo>(
      future: _getBusinessInfo(),
      initialData: initialBusiness,
      builder: (context, businessSnapshot) {
        final business = businessSnapshot.data ?? initialBusiness;
        return _buildWithBusiness(context, business);
      },
    );
  }

  Widget _buildWithBusiness(
    BuildContext context,
    ProductCardBusinessInfo business,
  ) {
    if (promotionResolved) {
      return _buildCardContent(
        context: context,
        business: business,
        promoInfo: promotionInfo,
        isPromotionLoading: false,
      );
    }

    if (!resolvePromotionIndependently) {
      return _buildCardContent(
        context: context,
        business: business,
        promoInfo: promotionInfo,
        isPromotionLoading: true,
      );
    }

    return FutureBuilder<ProductPromotionInfo?>(
      future: _controller.getPromotionForProduct(product),
      builder: (context, promotionSnapshot) {
        final isPromotionLoading =
            promotionSnapshot.connectionState == ConnectionState.waiting &&
            !promotionSnapshot.hasData;

        return _buildCardContent(
          context: context,
          business: business,
          promoInfo: promotionSnapshot.data,
          isPromotionLoading: isPromotionLoading,
        );
      },
    );
  }
}
