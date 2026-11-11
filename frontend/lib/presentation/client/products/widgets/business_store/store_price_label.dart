import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/client/products/widgets/business_store/skeleton_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StorePriceLabel extends StatelessWidget {
  final bool isLoading;
  final double currentPrice;
  final double? originalPrice;

  const StorePriceLabel({
    super.key,
    required this.isLoading,
    required this.currentPrice,
    this.originalPrice,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: const [
          SkeletonBox(width: 42, height: 8, radius: 6),
          SizedBox(height: 4),
          SkeletonBox(width: 48, height: 13, radius: 7),
        ],
      );
    }

    final hasDiscount = originalPrice != null && originalPrice! > currentPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasDiscount) StoreOriginalPrice(price: originalPrice!),
        Text(
          '\$${currentPrice.toStringAsFixed(2)}',
          style: TextStyle(
            color: RoleTheme.iconPayments,
            fontSize: 13.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class StoreOriginalPrice extends StatelessWidget {
  final double price;

  const StoreOriginalPrice({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: Text(
            '\$${price.toStringAsFixed(2)}',
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              height: 0.9.h,
              decoration: BoxDecoration(
                color: palette.mutedText.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
