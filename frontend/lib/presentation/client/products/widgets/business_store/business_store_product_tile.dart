import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/core/utils/product_category_display.dart';
import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';
import 'package:emprendedor/features/client/controllers/client_product_promotion_controller.dart';
import 'package:emprendedor/presentation/client/products/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BusinessStoreProductTile extends StatelessWidget {
  final ProductModel product;
  final ProductPromotionInfo? promotionInfo;
  final bool isPromotionLoading;
  final VoidCallback onTap;

  const BusinessStoreProductTile({
    super.key,
    required this.product,
    required this.promotionInfo,
    this.isPromotionLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final category = ProductCategoryDisplay.label(product.category);
    final promo = promotionInfo;

    final canApplyDiscount =
        promo?.isDiscountAvailableFor(product.price) ?? false;

    final discount = canApplyDiscount ? promo!.discountFor(product.price) : 0.0;

    final finalPrice = canApplyDiscount
        ? promo!.finalPrice(product.price)
        : product.price;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: RoleTheme.iconHealth.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 14.r,
                  offset: Offset(0, 6.h),
                ),
              ],
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        ProductImage(imageUrl: product.imageUrl, size: 82),
                        if (product.isFeatured) const ProductTopImageBadge(),
                      ],
                    ),
                    SizedBox(width: 11.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                    height: 1.08,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              StorePriceLabel(
                                isLoading: isPromotionLoading,
                                currentPrice: finalPrice,
                                originalPrice: canApplyDiscount && discount > 0
                                    ? product.price
                                    : null,
                              ),
                            ],
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            product.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.mutedText,
                              fontSize: 10.5.sp,
                              height: 1.25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 6.w,
                                runSpacing: 5.h,
                                children: [
                                  const ProductInfoChip(
                                    icon: Icons.verified_rounded,
                                    label: 'Validado',
                                    color: RoleTheme.iconValidation,
                                  ),
                                  if (product.approxCalories != null)
                                    ProductInfoChip(
                                      icon: Icons.local_fire_department_rounded,
                                      label:
                                          '${product.approxCalories!.toStringAsFixed(0)} kcal',
                                      color: RoleTheme.iconWarning,
                                    ),
                                ],
                              ),
                              SizedBox(height: 5.h),
                              Row(
                                children: [
                                  ProductInfoChip(
                                    icon: Icons.category_rounded,
                                    label: category,
                                    color: RoleTheme.iconHealth,
                                  ),
                                  if (promo != null) ...[
                                    SizedBox(width: 6.w),
                                    Flexible(
                                      child: ProductInfoChip(
                                        icon: Icons.local_offer_rounded,
                                        label: promo.availabilityLabel,
                                        color: RoleTheme.iconPromotion,
                                        maxWidth: 104.w,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: RoleTheme.iconColorFor(
                        Icons.chevron_right_rounded,
                        fallback: RoleTheme.iconInfo,
                      ),
                      size: 20.sp,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
