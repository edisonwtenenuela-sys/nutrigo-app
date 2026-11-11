import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';

class ProductDetailCard extends StatelessWidget {
  final OrderItem item;

  const ProductDetailCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final hasImage = item.imageUrl != null && item.imageUrl!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(7.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: RoleTheme.brandBorder.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: hasImage
                ? Image.network(
                    item.imageUrl!,
                    width: 66.w,
                    height: 66.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _placeholder();
                    },
                  )
                : _placeholder(),
          ),
          SizedBox(width: 9.w),
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
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Producto saludable preparado por el emprendimiento.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 11.5.sp,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: RoleTheme.iconPayments.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Text(
                    '\$${item.priceAtPurchase.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: RoleTheme.iconPayments,
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            'x${item.quantity}',
            style: TextStyle(
              color: palette.text,
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 66.w,
      height: 66.w,
      color: RoleTheme.brandChipBackground,
      child: Icon(
        Icons.restaurant_rounded,
        color: RoleTheme.iconColorFor(
          Icons.restaurant_rounded,
          fallback: RoleTheme.iconHealth,
        ),
        size: 26.sp,
      ),
    );
  }
}
