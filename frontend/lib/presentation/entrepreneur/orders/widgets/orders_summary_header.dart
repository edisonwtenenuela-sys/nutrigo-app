import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/order_controller.dart';

class OrdersSummaryHeader extends StatelessWidget {
  final OrderController controller;

  const OrdersSummaryHeader({
    super.key,
    required this.controller,
  });

  int get _pendingOrders {
    return controller.orders
        .where(
          (order) =>
      order.status == OrderStatus.pending ||
          order.status == OrderStatus.confirmed,
    )
        .length;
  }

  int get _deliveredOrders {
    return controller.orders
        .where((order) => order.status == OrderStatus.delivered)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: palette.primary.withValues(alpha: 0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: palette.primary.withValues(alpha: 0.04),
              blurRadius: 12.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 58.h,
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                  color: palette.primary.withValues(alpha: 0.18),
                ),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                color: RoleTheme.iconColorFor(
                  Icons.shopping_bag_outlined,
                  fallback: palette.primary,
                ),
                size: 25.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen de pedidos',
                    style: TextStyle(
                      color: palette.primary,
                      fontSize: 12.4.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 9.h),
                  Row(
                    children: [
                      _SummaryMetric(
                        value: '${controller.activeOrders}',
                        label: 'Activos',
                      ),
                      const _Divider(),
                      _SummaryMetric(
                        value: '$_pendingOrders',
                        label: 'Pend.',
                      ),
                      const _Divider(),
                      _SummaryMetric(
                        value: '$_deliveredOrders',
                        label: 'Entreg.',
                      ),
                      const _Divider(),
                      _SummaryMetric(
                        value:
                        '\$${controller.totalVentas.toStringAsFixed(2)}',
                        label: 'Ventas',
                        compact: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String value;
  final String label;
  final bool compact;

  const _SummaryMetric({
    required this.value,
    required this.label,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.primary,
              fontSize: compact ? 10.4.sp : 12.2.sp,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 8.2.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.w,
      height: 28.h,
      color: RoleTheme.entrepreneur.primary.withValues(alpha: 0.10),
    );
  }
}