import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ProductPriceSection extends StatelessWidget {
  final double price;
  final double? finalPrice;
  final double? discountAmount;

  const ProductPriceSection({
    super.key,
    required this.price,
    this.finalPrice,
    this.discountAmount,
  });

  bool get hasDiscount {
    return finalPrice != null &&
        discountAmount != null &&
        discountAmount! > 0 &&
        finalPrice! < price;
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    if (!hasDiscount) {
      return Text(
        '\$${price.toStringAsFixed(2)}',
        style: TextStyle(
          color: palette.primary,
          fontSize: 22.sp,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: TextStyle(
            color: palette.mutedText,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          '\$${finalPrice!.toStringAsFixed(2)}',
          style: TextStyle(
            color: palette.primary,
            fontSize: 23.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 5.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: RoleTheme.iconValidation.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            'Ahorras \$${discountAmount!.toStringAsFixed(2)}',
            style: TextStyle(
              color: RoleTheme.iconValidation,
              fontSize: 10.8.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
