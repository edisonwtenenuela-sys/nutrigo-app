import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';

class ProductsOrderCard extends StatelessWidget {
  final OrderItem item;

  const ProductsOrderCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final imageUrl = item.imageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final subtotal = item.quantity * item.priceAtPurchase;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: hasImage
                ? Image.network(
              imageUrl,
              width: 68.w,
              height: 68.w,
              fit: BoxFit.cover,
            )
                : Container(
              width: 68.w,
              height: 68.w,
              color: palette.primary.withValues(alpha: 0.06),
              child: Icon(
                Icons.fastfood_rounded,
                size: 28.sp,
                color: RoleTheme.iconColorFor(
                  Icons.fastfood_rounded,
                  fallback: palette.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: palette.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Text(
                        'x${item.quantity}',
                        style: TextStyle(
                          color: palette.primary,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        '\$${item.priceAtPurchase.toStringAsFixed(2)} c/u',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.mutedText,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '\$${subtotal.toStringAsFixed(2)}',
            style: TextStyle(
              color: palette.primary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}