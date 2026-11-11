import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/presentation/client/orders/helpers/client_orders_overview_helper.dart';

class ClientOrdersOverview extends StatelessWidget {
  final List<OrderModel> orders;

  const ClientOrdersOverview({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final totalSpent = ClientOrdersOverviewHelper.totalSpent(orders);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: RoleTheme.brandSurfaceTint.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(color: RoleTheme.iconOrders.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: RoleTheme.iconOrders.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: RoleTheme.iconColorFor(
                Icons.receipt_long_rounded,
                fallback: RoleTheme.iconOrders,
              ),
              size: 21.sp,
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seguimiento de pedidos',
                  maxLines: 2,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 14.2.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Estado e historial de compras.',
                  maxLines: 2,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 10.6.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(
                color: RoleTheme.iconPayments.withValues(alpha: 0.10),
              ),
            ),
            child: Text(
              '\$${totalSpent.toStringAsFixed(2)}',
              style: TextStyle(
                color: RoleTheme.iconPayments,
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
