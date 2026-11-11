import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';

class OrderDiscountBanner extends StatelessWidget {
  final OrderModel order;

  const OrderDiscountBanner({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final coupon = (order.couponCode?.trim().isNotEmpty ?? false)
        ? order.couponCode!
        : 'Aplicado';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: palette.accent.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: palette.accent.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_offer_rounded,
            color: palette.accent,
            size: 16.sp,
          ),
          SizedBox(width: 7.w),
          Expanded(
            child: Text(
              'Cupón $coupon • Descuento \$${order.discountAmount.toStringAsFixed(2)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.primary,
                fontSize: 10.8.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}