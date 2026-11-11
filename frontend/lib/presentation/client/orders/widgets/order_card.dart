import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_business_summary.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/features/client/controllers/client_order_business_controller.dart';
import 'package:emprendedor/presentation/client/orders/pages/index.dart';
import 'package:emprendedor/presentation/client/orders/widgets/index.dart';

class _OrderStatusUiData {
  final String label;
  final String trackingMessage;
  final Color color;

  const _OrderStatusUiData({
    required this.label,
    required this.trackingMessage,
    required this.color,
  });
}

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final String formattedDate;

  static final ClientOrderBusinessController _businessController =
      ClientOrderBusinessController();

  const OrderCard({
    super.key,
    required this.order,
    required this.formattedDate,
  });

  static const OrderCardBusinessInfo _defaultBusiness = OrderCardBusinessInfo(
    name: 'Emprendedor',
    imageUrl: null,
  );

  _OrderStatusUiData get _statusUiData {
    switch (order.status) {
      case OrderStatus.pending:
        return const _OrderStatusUiData(
          label: 'Pendiente',
          trackingMessage: 'Pedido recibido',
          color: RoleTheme.iconWarning,
        );
      case OrderStatus.confirmed:
        return const _OrderStatusUiData(
          label: 'Confirmado',
          trackingMessage: 'Pedido confirmado',
          color: RoleTheme.iconValidation,
        );
      case OrderStatus.preparing:
        return const _OrderStatusUiData(
          label: 'Preparando',
          trackingMessage: 'Preparando pedido',
          color: RoleTheme.iconWarning,
        );
      case OrderStatus.shipped:
        return const _OrderStatusUiData(
          label: 'En camino',
          trackingMessage: 'Pedido en camino',
          color: RoleTheme.iconValidation,
        );
      case OrderStatus.delivered:
        return const _OrderStatusUiData(
          label: 'Entregado',
          trackingMessage: 'Pedido entregado',
          color: RoleTheme.iconInfo,
        );
      case OrderStatus.cancelled:
        return const _OrderStatusUiData(
          label: 'Cancelado',
          trackingMessage: 'Pedido cancelado',
          color: RoleTheme.iconDanger,
        );
    }
  }

  String get _productName {
    if (order.items.isEmpty) return 'Producto saludable';
    return order.items.first.productName;
  }

  String? get _productImageUrl {
    if (order.items.isEmpty) return null;
    return order.items.first.imageUrl;
  }

  Color get _paymentColor {
    switch (order.paymentStatus) {
      case PaymentStatus.paid:
        return RoleTheme.iconPayments;
      case PaymentStatus.pending:
        return RoleTheme.iconWarning;
      case PaymentStatus.failed:
        return RoleTheme.iconDanger;
      case PaymentStatus.refunded:
        return RoleTheme.client.secondary;
    }
  }

  OrderCardBusinessInfo? _cachedBusinessInfo() {
    final summary = _businessController.getCachedBusinessSummary(order);
    return summary == null ? null : _businessInfoFromSummary(summary);
  }

  Stream<OrderCardBusinessInfo> _watchBusinessInfo() {
    return _businessController
        .watchBusinessSummary(order)
        .map(_businessInfoFromSummary);
  }

  OrderCardBusinessInfo _businessInfoFromSummary(OrderBusinessSummary summary) {
    return OrderCardBusinessInfo(
      name: summary.name,
      imageUrl: summary.imageUrl,
      rating: summary.rating,
      totalReviews: summary.totalReviews,
    );
  }

  void _openOrderDetail(BuildContext context) {
    AppNavigator.push(
      context,
      OrderDetailPage(order: order, formattedDate: formattedDate),
    );
  }

  Widget _buildCouponInfo(RolePalette palette) {
    if (!(order.hasDiscount && order.couponCode != null)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Row(
        children: [
          Icon(
            Icons.local_offer_rounded,
            color: RoleTheme.iconWarning,
            size: 13.sp,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              'Cupón ${order.couponCode} - Ahorraste \$${order.discountAmount.toStringAsFixed(2)}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: RoleTheme.iconWarning,
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessLine({
    required OrderCardBusinessInfo business,
    required RolePalette palette,
  }) {
    final hasReviews = business.totalReviews > 0 && business.rating > 0;
    final reviewText = hasReviews
        ? '${business.rating.toStringAsFixed(1)} (${business.totalReviews}) ${business.totalReviews == 1 ? 'reseña' : 'reseñas'}'
        : 'sin reseñas';

    return Row(
      children: [
        BusinessAvatar(imageUrl: business.imageUrl),
        SizedBox(width: 6.w),
        Expanded(
          child: RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: business.name,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 10.2.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: '  -  ',
                  style: TextStyle(
                    color: palette.mutedText.withValues(alpha: 0.65),
                    fontSize: 9.8.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    hasReviews ? Icons.star_rounded : Icons.star_border_rounded,
                    color: RoleTheme.iconRating,
                    size: 10.5.sp,
                  ),
                ),
                TextSpan(
                  text: ' $reviewText',
                  style: TextStyle(
                    color: palette.mutedText.withValues(alpha: 0.78),
                    fontSize: 9.8.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardContent({
    required BuildContext context,
    required OrderCardBusinessInfo business,
    required RolePalette palette,
  }) {
    final statusUi = _statusUiData;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.fromLTRB(11.w, 11.h, 11.w, 9.h),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(
          color: RoleTheme.brandBorder.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: RoleTheme.iconOrders.withValues(alpha: 0.035),
            blurRadius: 12.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImage(imageUrl: _productImageUrl),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.text,
                              fontSize: 13.2.sp,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        OrderSoftBadge(
                          label: statusUi.label,
                          color: statusUi.color,
                          icon: Icons.circle_rounded,
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    _buildBusinessLine(business: business, palette: palette),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        OrderInfoChip(
                          icon: Icons.receipt_rounded,
                          label: order.formattedOrderNumber.replaceFirst(
                            '#',
                            '',
                          ),
                          color: palette.secondary,
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: OrderInfoChip(
                            icon: Icons.payment_rounded,
                            label: getPaymentStatusDisplayString(
                              order.paymentStatus,
                            ),
                            color: _paymentColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          CompactTracking(
            status: order.status,
            message: statusUi.trackingMessage,
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                '\$ ${order.finalTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  color: RoleTheme.iconPayments,
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: 13.w),
              Container(
                width: 1.w,
                height: 16.h,
                color: RoleTheme.brandBorder.withValues(alpha: 0.55),
              ),
              SizedBox(width: 13.w),
              Icon(
                Icons.calendar_month_rounded,
                color: RoleTheme.iconCalendar,
                size: 12.5.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                formattedDate,
                style: TextStyle(
                  color: palette.mutedText,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(999.r),
                onTap: () => _openOrderDetail(context),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 5.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ver detalle',
                        style: TextStyle(
                          color: RoleTheme.iconInfo,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: RoleTheme.iconInfo,
                        size: 15.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildCouponInfo(palette),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return StreamBuilder<OrderCardBusinessInfo>(
      stream: _watchBusinessInfo(),
      initialData: _cachedBusinessInfo(),
      builder: (context, snapshot) {
        final business = snapshot.data ?? _defaultBusiness;
        return _buildCardContent(
          context: context,
          business: business,
          palette: palette,
        );
      },
    );
  }
}
