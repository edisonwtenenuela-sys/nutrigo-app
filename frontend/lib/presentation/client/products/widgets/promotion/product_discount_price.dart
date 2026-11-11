import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ProductDiscountPrice extends StatelessWidget {
  final double originalPrice;
  final double finalPrice;
  final double discountAmount;

  const ProductDiscountPrice({
    super.key,
    required this.originalPrice,
    required this.finalPrice,
    required this.discountAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\$${originalPrice.toStringAsFixed(2)}',
          style: TextStyle(
            color: RoleTheme.brandMutedText,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.lineThrough,
            decorationThickness: 2,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          '\$${finalPrice.toStringAsFixed(2)}',
          style: TextStyle(
            color: RoleTheme.iconPayments,
            fontSize: 24.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 5.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: RoleTheme.iconValidation.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Text(
            'Ahorras \$${discountAmount.toStringAsFixed(2)}',
            style: TextStyle(
              color: RoleTheme.iconValidation,
              fontSize: 10.8.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
