import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/client/products/widgets/product_card/price_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PriceLabel extends StatelessWidget {
  final bool isLoading;
  final double currentPrice;
  final double? originalPrice;

  const PriceLabel({
    super.key,
    required this.isLoading,
    required this.currentPrice,
    this.originalPrice,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          PriceSkeleton(width: 34.w, height: 7.h),
          SizedBox(height: 3.h),
          PriceSkeleton(width: 42.w, height: 12.h),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (originalPrice != null) ...[
          Text(
            '\$${originalPrice!.toStringAsFixed(2)}',
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 8.sp,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.lineThrough,
              decorationThickness: 2,
            ),
          ),
          SizedBox(height: 1.h),
        ],
        Text(
          '\$${currentPrice.toStringAsFixed(2)}',
          style: TextStyle(
            color: RoleTheme.iconPayments,
            fontSize: 12.6.sp,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ],
    );
  }
}
