import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/features/client/controllers/index.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/client/appointments/pages/client_appointments_page.dart';
import 'package:emprendedor/presentation/client/cart/pages/cart_page.dart';

class QuickSummarySection extends StatelessWidget {
  const QuickSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final orderController = context.watch<ClientOrderController>();
    final appointmentController = context.watch<AppointmentController>();
    final cartController = context.watch<CartController>();
    const palette = RoleTheme.client;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen rápido',
          style: TextStyle(
            color: palette.text,
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Pedidos',
                value: '${orderController.orders.length}',
                icon: Icons.receipt_long_rounded,
                color: RoleTheme.iconOrders,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _SummaryCard(
                title: 'Citas',
                value: '${appointmentController.appointmentsCount}',
                icon: Icons.event_rounded,
                color: RoleTheme.iconCalendar,
                onTap: () {
                  AppNavigator.push(context, const ClientAppointmentsPage());
                },
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _SummaryCard(
                title: 'Carrito',
                value: '${cartController.items.length}',
                icon: Icons.shopping_bag_rounded,
                color: RoleTheme.iconCart,
                onTap: () {
                  AppNavigator.push(context, const CartPage());
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final semanticIconColor = RoleTheme.iconColorFor(icon, fallback: color);

    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Container(
          height: 90.h,
          padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 6.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: semanticIconColor.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 29.w,
                height: 29.w,
                decoration: BoxDecoration(
                  color: semanticIconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: semanticIconColor, size: 15.5.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.mutedText,
                  fontSize: 9.2.sp,
                  height: 1.05,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}








