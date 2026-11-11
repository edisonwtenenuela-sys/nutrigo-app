import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/presentation/entrepreneur/orders/widgets/detail/detail_row.dart';

class OrderInfoCard extends StatelessWidget {
  final OrderModel order;
  final DateFormat dateFormat;
  final Color Function(OrderStatus) getStatusColor;
  final Color Function(PaymentStatus) getPaymentStatusColor;

  const OrderInfoCard({
    super.key,
    required this.order,
    required this.dateFormat,
    required this.getStatusColor,
    required this.getPaymentStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: [
          DetailRow(
            label: 'Pedido',
            value: order.formattedOrderNumber,
            icon: Icons.tag_rounded,
            isBold: true,
          ),
          DetailRow(
            label: 'Estado',
            value: getOrderStatusDisplayString(order.status),
            icon: Icons.local_shipping_outlined,
            valueColor: getStatusColor(order.status),
            isBold: true,
          ),
          DetailRow(
            label: 'Pago',
            value: getPaymentStatusDisplayString(order.paymentStatus),
            icon: Icons.payments_outlined,
            valueColor: getPaymentStatusColor(order.paymentStatus),
            isBold: true,
          ),
          DetailRow(
            label: 'Fecha del pedido',
            value: dateFormat.format(order.createdAt.toDate()),
            icon: Icons.calendar_month_outlined,
          ),
          if (order.deliveredAt != null)
            DetailRow(
              label: 'Fecha de entrega',
              value: dateFormat.format(order.deliveredAt!.toDate()),
              icon: Icons.check_circle_outline_rounded,
            ),
          DetailRow(
            label: 'Método de pago',
            value: order.paymentMethod,
            icon: Icons.credit_card_outlined,
          ),
          if (order.hasDiscount) ...[
            DetailRow(
              label: 'Subtotal',
              value: '\$${order.originalTotal.toStringAsFixed(2)}',
              icon: Icons.receipt_long_rounded,
            ),
            DetailRow(
              label: 'Descuento',
              value: '-\$${order.discountAmount.toStringAsFixed(2)}',
              icon: Icons.discount_rounded,
              valueColor: RoleTheme.iconValidation,
              isBold: true,
            ),
            if (order.couponCode != null &&
                order.couponCode!.trim().isNotEmpty)
              DetailRow(
                label: 'Cupón',
                value: order.couponCode!,
                icon: Icons.local_offer_rounded,
                valueColor: RoleTheme.iconWarning,
                isBold: true,
              ),
          ],
          DetailRow(
            label: order.hasDiscount ? 'Total final' : 'Total',
            value: '\$${order.finalTotal.toStringAsFixed(2)}',
            icon: Icons.attach_money_rounded,
            valueColor: palette.primary,
            isBold: true,
          ),
        ],
      ),
    );
  }
}