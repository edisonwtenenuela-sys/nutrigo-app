import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import '../../card/product_image.dart';

class OrderProductsCarousel extends StatefulWidget {
  final List<OrderItem> items;

  const OrderProductsCarousel({super.key, required this.items});

  @override
  State<OrderProductsCarousel> createState() => _OrderProductsCarouselState();
}

class _OrderProductsCarouselState extends State<OrderProductsCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final items = widget.items;
    final total = items.length;

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Productos del pedido',
                style: TextStyle(
                  color: palette.text,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: RoleTheme.iconOrders.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                '${_currentIndex + 1} de $total',
                style: TextStyle(
                  color: RoleTheme.iconOrders,
                  fontSize: 9.8.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        if (total > 1) ...[
          SizedBox(height: 3.h),
          Text(
            'Desliza para ver todos los productos →',
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 10.2.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        SizedBox(height: 7.h),
        SizedBox(
          height: 100.h,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: total,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: total > 1 ? 5.w : 0),
                child: _OrderProductSlide(item: items[index]),
              );
            },
          ),
        ),
        if (total > 1) ...[
          SizedBox(height: 7.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(total, (index) {
              final selected = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 17.w : 6.w,
                height: 6.w,
                margin: EdgeInsets.symmetric(horizontal: 2.5.w),
                decoration: BoxDecoration(
                  color: selected
                      ? RoleTheme.iconOrders
                      : RoleTheme.brandBorder.withValues(alpha: 0.80),
                  borderRadius: BorderRadius.circular(999.r),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _OrderProductSlide extends StatelessWidget {
  final OrderItem item;

  const _OrderProductSlide({required this.item});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final hasImage = item.imageUrl != null && item.imageUrl!.trim().isNotEmpty;
    final total = item.priceAtPurchase * item.quantity;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(9.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: RoleTheme.brandBorder.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: RoleTheme.iconOrders.withValues(alpha: 0.035),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          ProductImage(imageUrl: hasImage ? item.imageUrl : null),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 12.7.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.06,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Producto saludable preparado por el emprendimiento.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 10.sp,
                    height: 1.12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: RoleTheme.iconPayments.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: RoleTheme.iconPayments,
                          fontSize: 10.3.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: RoleTheme.brandSurfaceTint.withValues(
                          alpha: 0.45,
                        ),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        'x${item.quantity}',
                        style: TextStyle(
                          color: palette.text,
                          fontSize: 10.3.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}