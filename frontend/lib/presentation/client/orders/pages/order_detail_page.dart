import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_business_summary.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/data/repositories/shared/order_repository.dart';
import 'package:emprendedor/features/client/controllers/client_order_business_controller.dart';
import 'package:emprendedor/presentation/client/orders/widgets/index.dart';

class _OrderStatusUiData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _OrderStatusUiData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class OrderDetailPage extends StatelessWidget {
  final OrderModel order;
  final String formattedDate;

  OrderDetailPage({
    super.key,
    required this.order,
    required this.formattedDate,
  });

  final ClientOrderBusinessController _businessController =
      ClientOrderBusinessController();
  final OrderRepository _orderRepository = OrderRepository();

  static const OrderDetailBusinessInfo _fallbackBusiness =
      OrderDetailBusinessInfo(
        name: 'Emprendedor',
        imageUrl: null,
        rating: 0,
        totalReviews: 0,
      );

  Widget _vGap(double value) => SizedBox(height: value.h);

  OrderDetailBusinessInfo _businessInfoFromSummary(
    OrderBusinessSummary summary,
  ) {
    return OrderDetailBusinessInfo(
      name: summary.name,
      imageUrl: summary.imageUrl,
      rating: summary.rating,
      totalReviews: summary.totalReviews,
    );
  }

  Stream<OrderDetailBusinessInfo> _watchBusinessInfo(OrderModel order) {
    return _businessController
        .watchBusinessSummary(order)
        .map(_businessInfoFromSummary);
  }

  _OrderStatusUiData _statusUiData(OrderModel order) {
    switch (order.status) {
      case OrderStatus.pending:
        return const _OrderStatusUiData(
          title: 'Pedido recibido',
          subtitle: 'Esperando confirmación del emprendimiento.',
          icon: Icons.schedule_rounded,
          color: RoleTheme.iconWarning,
        );
      case OrderStatus.confirmed:
        return const _OrderStatusUiData(
          title: 'Pedido confirmado',
          subtitle: 'El emprendimiento confirmó tu pedido.',
          icon: Icons.check_circle_rounded,
          color: RoleTheme.iconValidation,
        );
      case OrderStatus.preparing:
        return const _OrderStatusUiData(
          title: 'Pedido en preparación',
          subtitle: 'Tu pedido está siendo preparado.',
          icon: Icons.restaurant_rounded,
          color: RoleTheme.iconWarning,
        );
      case OrderStatus.shipped:
        return const _OrderStatusUiData(
          title: 'Pedido en camino',
          subtitle: 'Tu pedido va camino a tu ubicación.',
          icon: Icons.delivery_dining_rounded,
          color: RoleTheme.iconInfo,
        );
      case OrderStatus.delivered:
        return const _OrderStatusUiData(
          title: 'Pedido entregado',
          subtitle: 'Tu pedido fue entregado correctamente.',
          icon: Icons.verified_rounded,
          color: RoleTheme.iconValidation,
        );
      case OrderStatus.cancelled:
        return const _OrderStatusUiData(
          title: 'Pedido cancelado',
          subtitle: 'Este pedido fue cancelado.',
          icon: Icons.close_rounded,
          color: RoleTheme.iconDanger,
        );
    }
  }

  String _paymentMethodText(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Efectivo';
      case 'card':
        return 'Tarjeta';
      case 'stripe':
      case 'online':
        return 'Pago en línea';
      default:
        return method;
    }
  }

  bool _canReviewDeliveredOrder(OrderModel order) {
    return order.status == OrderStatus.delivered && order.id != null;
  }

  Future<OrderModel?>? _waitForNumberIfNeeded() {
    final orderId = order.id;
    if (order.hasOrderNumber || orderId == null || orderId.trim().isEmpty) {
      return null;
    }

    return _orderRepository.waitForClientOrderNumber(
      orderId: orderId,
      userId: order.userId,
      timeout: const Duration(seconds: 6),
    );
  }

  Widget _buildOrderContent(
    OrderModel order,
    OrderDetailBusinessInfo business,
  ) {
    final statusUi = _statusUiData(order);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusHeader(
            title: statusUi.title,
            subtitle: statusUi.subtitle,
            icon: statusUi.icon,
            color: statusUi.color,
          ),
          _vGap(8),
          const SectionTitle(title: 'Emprendedor'),
          _vGap(4),
          BusinessCard(business: business),
          _vGap(8),
          OrderProgress(status: order.status),
          _vGap(8),
          InfoPanel(
            order: order,
            formattedDate: formattedDate,
            paymentMethodText: _paymentMethodText(order.paymentMethod),
          ),
          _vGap(8),
          if (order.items.isEmpty)
            const EmptyProductsCard()
          else
            OrderProductsCarousel(items: order.items),
          _vGap(10),
          TotalPaidCard(
            total: order.finalTotal,
            subtotal: order.originalTotal,
            discountAmount: order.discountAmount,
            couponCode: order.couponCode,
          ),
          if (_canReviewDeliveredOrder(order)) ...[
            _vGap(10),
            ReviewButton(order: order, business: business),
          ],
        ],
      ),
    );
  }

  AppBar _buildAppBar(OrderModel order) {
    return AppBar(
      backgroundColor: RoleTheme.client.background,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 46.h,
      title: Text(
        'Pedido ${order.formattedOrderNumber}',
        style: TextStyle(
          color: RoleTheme.client.text,
          fontWeight: FontWeight.w900,
          fontSize: 17.sp,
        ),
      ),
    );
  }

  Widget _buildPageBody(OrderModel order, OrderDetailBusinessInfo business) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: _buildOrderContent(order, business),
      ),
    );
  }

  Widget _buildResolvedOrderScaffold(OrderModel displayedOrder) {
    final cachedSummary = _businessController.getCachedBusinessSummary(
      displayedOrder,
    );

    return StreamBuilder<OrderDetailBusinessInfo>(
      stream: _watchBusinessInfo(displayedOrder),
      initialData: cachedSummary == null
          ? null
          : _businessInfoFromSummary(cachedSummary),
      builder: (context, snapshot) {
        final business = snapshot.data ?? _fallbackBusiness;
        return Scaffold(
          backgroundColor: RoleTheme.client.background,
          appBar: _buildAppBar(displayedOrder),
          body: _buildPageBody(displayedOrder, business),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrderModel?>(
      future: _waitForNumberIfNeeded(),
      initialData: order,
      builder: (context, snapshot) {
        return _buildResolvedOrderScaffold(snapshot.data ?? order);
      },
    );
  }
}
