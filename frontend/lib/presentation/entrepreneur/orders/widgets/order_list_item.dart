import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/presentation/entrepreneur/orders/pages/order_detail_page.dart';
import 'package:emprendedor/presentation/entrepreneur/orders/widgets/list/order_item_icon.dart';
import 'package:emprendedor/presentation/entrepreneur/orders/widgets/list/mini_order_progress.dart';

class OrderListItem extends StatelessWidget {
  final OrderModel order;

  const OrderListItem({super.key, required this.order});

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.pending:
        return RoleTheme.iconWarning;
      case OrderStatus.confirmed:
        return RoleTheme.entrepreneur.primary;
      case OrderStatus.preparing:
        return RoleTheme.entrepreneur.secondary;
      case OrderStatus.shipped:
        return RoleTheme.iconInfo;
      case OrderStatus.delivered:
        return RoleTheme.iconValidation;
      case OrderStatus.cancelled:
        return RoleTheme.iconDanger;
    }
  }

  String get _statusLabel {
    switch (order.status) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.preparing:
        return 'Preparando';
      case OrderStatus.shipped:
        return 'En camino';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  String get _paymentLabel {
    switch (order.paymentStatus) {
      case PaymentStatus.pending:
        return 'Pendiente';
      case PaymentStatus.paid:
        return 'Pagado';
      case PaymentStatus.failed:
        return 'Fallido';
      case PaymentStatus.refunded:
        return 'Reembolso';
    }
  }

  String get _customerName {
    final name = order.customerInfo.name.trim();
    return name.isEmpty ? 'Cliente' : name;
  }

  void _openDetail(BuildContext context) {
    final id = order.id;
    if (id == null) return;

    AppNavigator.push(context, OrderDetailPage(orderId: id));
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a', 'es');
    final statusColor = _statusColor;

    return Container(
      margin: EdgeInsets.only(bottom: 11.h),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(17.r),
        onTap: () => _openDetail(context),
        child: Padding(
          padding: EdgeInsets.all(11.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrderItemIcon(color: statusColor),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pedido ${order.formattedOrderNumber}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.text,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _customerName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.mutedText,
                            fontSize: 10.6.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              color: RoleTheme.iconCalendar,
                              size: 12.sp,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                dateFormat.format(order.createdAt.toDate()),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: palette.mutedText,
                                  fontSize: 9.3.sp,
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
                  Padding(
                    padding: EdgeInsets.only(right: 2.w),
                    child: SizedBox(
                      width: 76.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _StatusPill(label: _statusLabel, color: statusColor),
                          SizedBox(height: 5.h),
                          Text(
                            'Ver detalle >',
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: palette.primary,
                              fontSize: 8.8.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: palette.background,
                  borderRadius: BorderRadius.circular(13.r),
                  border: Border.all(
                    color: palette.primary.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    _MiniMetric(
                      value: '${order.items.length}',
                      label: 'Productos',
                    ),
                    const _MetricDivider(),
                    _MiniMetric(
                      value: '\$${order.finalTotal.toStringAsFixed(2)}',
                      label: 'Total',
                    ),
                    const _MetricDivider(),
                    _MiniMetric(
                      value: _paymentMethodLabel(order.paymentMethod),
                      label: _paymentLabel,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 9.h),
              MiniOrderProgress(status: order.status),
            ],
          ),
        ),
      ),
    );
  }

  String _paymentMethodLabel(String method) {
    switch (method.toLowerCase()) {
      case 'stripe':
      case 'online':
      case 'card':
        return 'Online';
      case 'cash':
        return 'Efectivo';
      default:
        return method.isEmpty ? 'Pago' : method;
    }
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 8.8.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String value;
  final String label;

  const _MiniMetric({required this.value, required this.label});

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
              color: palette.text,
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 8.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.w,
      height: 28.h,
      color: RoleTheme.entrepreneur.primary.withValues(alpha: 0.10),
    );
  }
}
