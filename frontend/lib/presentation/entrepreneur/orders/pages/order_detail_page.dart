import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';
import 'package:emprendedor/presentation/entrepreneur/orders/dialogs/update_order_status_dialog.dart';
import 'package:emprendedor/presentation/entrepreneur/orders/widgets/list/mini_order_progress.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  static const _pageBackground = RoleTheme.brandBackground;
  static const _refreshColor = RoleTheme.brandPrimary;

  late final EntrepreneurOrderDetailController _screenController;

  @override
  void initState() {
    super.initState();
    _screenController = EntrepreneurOrderDetailController(
      orderId: widget.orderId,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _screenController.loadInitial(context.read<OrderController>());
    });
  }

  Future<void> _openInMaps(double lat, double lng) async {
    final result = await _screenController.openDeliveryLocation(
      latitude: lat,
      longitude: lng,
    );

    if (result != null) {
      await _showActionResult(result);
    }
  }

  Future<void> _refreshOrderDetails() async {
    await _screenController.refresh(context.read<OrderController>());
  }

  void _showFeedback({
    required AppFeedbackType type,
    required String title,
    required String message,
  }) {
    showAppMessage(
      context,
      role: AppFeedbackRole.entrepreneur,
      type: type,
      title: title,
      message: message,
    );
  }

  Future<void> _showActionResult(EntrepreneurOrderActionResult result) async {
    if (!mounted) return;
    _showFeedback(
      type: result.type.toPresentationType(),
      title: result.title,
      message: result.message,
    );
  }

  Future<void> _openManualStatusDialog(OrderModel order) async {
    final orderId = order.id;
    if (orderId == null) return;

    final controller = context.read<OrderController>();
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => UpdateOrderStatusDialog(
        orderId: orderId,
        currentStatus: order.status,
      ),
    );

    if (!mounted) return;

    final result = await _screenController.manualUpdateResult(
      controller,
      updated,
    );

    if (result != null) {
      await _showActionResult(result);
    }
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator(color: _refreshColor));
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: RoleTheme.entrepreneur.text,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderNotFoundState() {
    return Center(
      child: Text(
        'No se pudo cargar el pedido.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: RoleTheme.entrepreneur.text,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _pageBackground,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Detalle del pedido',
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildOrderDetailsContent(OrderModel order, DateFormat dateFormat) {
    return RefreshIndicator(
      color: _refreshColor,
      onRefresh: _refreshOrderDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _OrderHeroCard(order: order, dateFormat: dateFormat),
            SizedBox(height: 10.h),
            _ProductsBlock(order: order),
            SizedBox(height: 10.h),
            _DeliveryInfoBlock(
              order: order,
              dateFormat: dateFormat,
              onOpenMaps: order.latitude != null && order.longitude != null
                  ? () => _openInMaps(order.latitude!, order.longitude!)
                  : null,
            ),
            SizedBox(height: 10.h),
            _TrackingBlock(
              order: order,
              onUpdateStatus: order.canChangeStatus
                  ? () => _openManualStatusDialog(order)
                  : null,
            ),
            SizedBox(height: 10.h),
            _CustomerBlock(order: order),
          ],
        ),
      ),
    );
  }

  Widget _buildPageBody(OrderController controller, DateFormat dateFormat) {
    final uiState = _screenController.resolveUiState(controller);

    if (uiState == EntrepreneurOrderDetailUiState.loading) {
      return _buildLoadingState();
    }

    if (uiState == EntrepreneurOrderDetailUiState.error) {
      return _buildErrorState(controller.errorMessage!);
    }

    if (uiState == EntrepreneurOrderDetailUiState.notFound) {
      return _buildOrderNotFoundState();
    }

    final order = controller.selectedOrder!;
    return _buildOrderDetailsContent(order, dateFormat);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a', 'es');

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: _buildAppBar(),
      body: Consumer<OrderController>(
        builder: (context, controller, child) {
          return _buildPageBody(controller, dateFormat);
        },
      ),
    );
  }
}

class _OrderHeroCard extends StatelessWidget {
  final OrderModel order;
  final DateFormat dateFormat;

  const _OrderHeroCard({required this.order, required this.dateFormat});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    final customerName = order.customerInfo.name.trim().isEmpty
        ? 'Cliente'
        : order.customerInfo.name.trim();

    return _SurfaceCard(
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          Container(
            width: 45.w,
            height: 45.w,
            decoration: BoxDecoration(
              color: RoleTheme.entrepreneur.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: RoleTheme.iconColorFor(
                Icons.shopping_bag_outlined,
                fallback: RoleTheme.entrepreneur.primary,
              ),
              size: 23.sp,
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pedido ${order.formattedOrderNumber}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RoleTheme.entrepreneur.text,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  customerName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RoleTheme.entrepreneur.mutedText,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: RoleTheme.iconColorFor(
                        Icons.calendar_month_outlined,
                        fallback: RoleTheme.entrepreneur.mutedText,
                      ),
                      size: 12.sp,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        dateFormat.format(order.createdAt.toDate()),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: RoleTheme.entrepreneur.mutedText,
                          fontSize: 9.5.sp,
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
          _StatusChip(status: order.status, color: statusColor),
        ],
      ),
    );
  }
}

class _ProductsBlock extends StatelessWidget {
  final OrderModel order;

  const _ProductsBlock({required this.order});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: EdgeInsets.all(11.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Productos',
            style: TextStyle(
              color: RoleTheme.entrepreneur.text,
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8.h),
          ...order.items.map((item) => _ProductRow(item: item)),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final OrderItem item;

  const _ProductRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final hasImage = item.imageUrl != null && item.imageUrl!.trim().isNotEmpty;
    final total = item.quantity * item.priceAtPurchase;

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              width: 50.r,
              height: 50.r,
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fadeInDuration: const Duration(milliseconds: 120),
                      memCacheWidth: 220,
                      memCacheHeight: 220,
                      imageBuilder: (context, imageProvider) => DecoratedBox(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Container(
                        color: RoleTheme.entrepreneur.primary.withValues(
                          alpha: 0.06,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: RoleTheme.entrepreneur.primary.withValues(
                          alpha: 0.06,
                        ),
                        child: Icon(
                          Icons.restaurant_rounded,
                          color: RoleTheme.iconColorFor(
                            Icons.restaurant_rounded,
                          ),
                          size: 20.sp,
                        ),
                      ),
                    )
                  : Container(
                      color: RoleTheme.entrepreneur.primary.withValues(
                        alpha: 0.06,
                      ),
                      child: Icon(
                        Icons.restaurant_rounded,
                        color: RoleTheme.iconColorFor(Icons.restaurant_rounded),
                        size: 20.sp,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              item.productName,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: RoleTheme.entrepreneur.text,
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w800,
                height: 1.12,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'x${item.quantity}',
                style: TextStyle(
                  color: RoleTheme.entrepreneur.text,
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  color: RoleTheme.entrepreneur.text,
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeliveryInfoBlock extends StatelessWidget {
  final OrderModel order;
  final DateFormat dateFormat;
  final VoidCallback? onOpenMaps;

  const _DeliveryInfoBlock({
    required this.order,
    required this.dateFormat,
    required this.onOpenMaps,
  });

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.location_on_outlined,
            title: 'Direcci\u00f3n',
            value: order.shippingAddress,
            actionLabel: onOpenMaps == null ? null : 'Ver en mapa',
            onTap: onOpenMaps,
          ),
          const _SoftDivider(),
          _InfoRow(
            icon: Icons.payment_outlined,
            title: 'M\u00e9todo de pago',
            value: _paymentMethodLabel(order.paymentMethod),
          ),
          const _SoftDivider(),
          _InfoRow(
            icon: Icons.note_alt_outlined,
            title: 'Notas del cliente',
            value: 'Sin notas',
          ),
          const _SoftDivider(),
          _InfoRow(
            icon: Icons.calendar_month_outlined,
            title: 'Fecha',
            value: dateFormat.format(order.createdAt.toDate()),
          ),
        ],
      ),
    );
  }
}

class _TrackingBlock extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onUpdateStatus;

  const _TrackingBlock({required this.order, required this.onUpdateStatus});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado del pedido',
            style: TextStyle(
              color: RoleTheme.entrepreneur.text,
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10.h),
          MiniOrderProgress(status: order.status),
          if (onUpdateStatus != null) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUpdateStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: RoleTheme.entrepreneur.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13.r),
                  ),
                ),
                child: Text(
                  'Actualizar estado',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CustomerBlock extends StatelessWidget {
  final OrderModel order;

  const _CustomerBlock({required this.order});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 5.h),
            child: Text(
              'Informaci\u00f3n del cliente',
              style: TextStyle(
                color: RoleTheme.entrepreneur.text,
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _InfoRow(
            icon: Icons.person_outline_rounded,
            title: 'Nombre',
            value: order.customerInfo.name.trim().isEmpty
                ? 'Cliente'
                : order.customerInfo.name.trim(),
          ),
          const _SoftDivider(),
          _InfoRow(
            icon: Icons.phone_outlined,
            title: 'Tel\u00e9fono',
            value: order.customerInfo.phoneNumber?.trim().isNotEmpty == true
                ? order.customerInfo.phoneNumber!.trim()
                : 'No registrado',
          ),
          const _SoftDivider(),
          _InfoRow(
            icon: Icons.email_outlined,
            title: 'Email',
            value: order.customerInfo.email.trim().isEmpty
                ? 'No registrado'
                : order.customerInfo.email.trim(),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? actionLabel;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    this.actionLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
        child: Row(
          children: [
            Icon(icon, color: RoleTheme.iconColorFor(icon), size: 17.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: RoleTheme.entrepreneur.text,
                      fontSize: 10.8.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: RoleTheme.entrepreneur.mutedText,
                      fontSize: 10.sp,
                      height: 1.18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (actionLabel != null) ...[
              SizedBox(width: 8.w),
              Text(
                actionLabel!,
                style: TextStyle(
                  color: RoleTheme.entrepreneur.primary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;
  final Color color;

  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        _statusLabel(status),
        maxLines: 2,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 9.4.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SurfaceCard({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: RoleTheme.entrepreneur.surface,
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(color: Colors.black.withValues(alpha: 0.045)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.018),
            blurRadius: 12.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1.h,
      indent: 42.w,
      endIndent: 12.w,
      color: Colors.black.withValues(alpha: 0.07),
    );
  }
}

Color _statusColor(OrderStatus status) {
  switch (status) {
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

String _statusLabel(OrderStatus status) {
  switch (status) {
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

String _paymentMethodLabel(String method) {
  switch (method.toLowerCase()) {
    case 'stripe':
    case 'online':
    case 'card':
      return 'Online';
    case 'cash':
      return 'Efectivo';
    default:
      return method.isEmpty ? 'No especificado' : method;
  }
}
