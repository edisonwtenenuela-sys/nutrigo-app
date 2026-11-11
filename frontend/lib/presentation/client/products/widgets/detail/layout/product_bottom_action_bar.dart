import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ProductBottomActionBar extends StatelessWidget {
  final bool enabled;
  final double price;
  final double? originalPrice;
  final VoidCallback onAddToCart;

  const ProductBottomActionBar({
    super.key,
    required this.enabled,
    required this.price,
    required this.onAddToCart,
    this.originalPrice,
  });

  bool get _hasDiscount {
    final sourcePrice = originalPrice;
    if (sourcePrice == null) return false;
    return sourcePrice > price + 0.009;
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 10.h),
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border(
            top: BorderSide(color: palette.primary.withValues(alpha: 0.08)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10.r,
              offset: Offset(0, -2.h),
            ),
          ],
        ),
        child: SizedBox(
          height: 48.h,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: enabled ? onAddToCart : null,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: palette.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: palette.primary.withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 21.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Agregar al carrito',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 20.h,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
                SizedBox(width: 12.w),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_hasDiscount) ...[
                        Text(
                          '\$${originalPrice!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withValues(alpha: 0.72),
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.white.withValues(
                              alpha: 0.80,
                            ),
                            decorationThickness: 2,
                          ),
                        ),
                        SizedBox(width: 6.w),
                      ],
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w900,
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
}
