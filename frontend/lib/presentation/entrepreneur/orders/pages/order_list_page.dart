import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';
import 'package:emprendedor/presentation/entrepreneur/orders/widgets/order_list_item.dart';
import 'package:emprendedor/presentation/entrepreneur/orders/widgets/orders_empty_state.dart';
import 'package:emprendedor/presentation/entrepreneur/orders/widgets/orders_summary_header.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';
import 'package:emprendedor/presentation/shared/widgets/common/app_error_state.dart';

enum _OrderListFilter {
  all,
  pending,
  confirmed,
  preparing,
  shipped,
  delivered,
  cancelled,
}

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final EntrepreneurOrderListController _screenController =
      EntrepreneurOrderListController();
  final TextEditingController _searchController = TextEditingController();

  bool _initialized = false;
  _OrderListFilter _filter = _OrderListFilter.all;
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    await _screenController.loadOrders(context.read<OrderController>());
  }

  void _showControllerError(OrderController controller) {
    final message = _screenController.consumeNewError(controller);
    if (message == null) return;

    final normalized = message.toLowerCase();
    final isActionError =
        normalized.contains('actualizar el estado') ||
        normalized.contains('actualizar el pago');

    if (isActionError) return;

    showAppMessage(
      context,
      role: AppFeedbackRole.entrepreneur,
      type: AppFeedbackType.error,
      title: 'No se pudo cargar',
      message: message,
    );
  }

  List<OrderModel> _visibleOrders(List<OrderModel> orders) {
    final normalizedQuery = _query.trim().toLowerCase();

    return orders.where((order) {
      final matchesFilter = switch (_filter) {
        _OrderListFilter.all => true,
        _OrderListFilter.pending => order.status == OrderStatus.pending,
        _OrderListFilter.confirmed => order.status == OrderStatus.confirmed,
        _OrderListFilter.preparing => order.status == OrderStatus.preparing,
        _OrderListFilter.shipped => order.status == OrderStatus.shipped,
        _OrderListFilter.delivered => order.status == OrderStatus.delivered,
        _OrderListFilter.cancelled => order.status == OrderStatus.cancelled,
      };

      if (!matchesFilter) return false;
      if (normalizedQuery.isEmpty) return true;

      final customerName = order.customerInfo.name.toLowerCase();
      final customerEmail = order.customerInfo.email.toLowerCase();
      final orderNumber = order.formattedOrderNumber.toLowerCase();
      final paymentMethod = order.paymentMethod.toLowerCase();

      return customerName.contains(normalizedQuery) ||
          customerEmail.contains(normalizedQuery) ||
          orderNumber.contains(normalizedQuery) ||
          paymentMethod.contains(normalizedQuery);
    }).toList();
  }

  Widget _buildLoadingState(RolePalette palette) {
    return Center(child: CircularProgressIndicator(color: palette.primary));
  }

  Widget _buildErrorState(OrderController controller) {
    return AppErrorState(
      message: controller.errorMessage!,
      onRetry: _loadOrders,
    );
  }

  Widget _buildEmptyState(RolePalette palette) {
    return RefreshIndicator(
      color: palette.primary,
      onRefresh: _loadOrders,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 96.h),
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 114.h,
                ),
                child: const Center(child: OrdersEmptyState()),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearch(RolePalette palette) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42.h,
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Buscar pedido, cliente o número...',
                  hintStyle: TextStyle(
                    color: palette.mutedText.withValues(alpha: 0.72),
                    fontSize: 11.2.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: palette.mutedText,
                    size: 18.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 11.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: palette.primary,
              size: 19.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(RolePalette palette, List<OrderModel> orders) {
    int countFor(_OrderListFilter filter) {
      return orders.where((order) {
        return switch (filter) {
          _OrderListFilter.all => true,
          _OrderListFilter.pending => order.status == OrderStatus.pending,
          _OrderListFilter.confirmed => order.status == OrderStatus.confirmed,
          _OrderListFilter.preparing => order.status == OrderStatus.preparing,
          _OrderListFilter.shipped => order.status == OrderStatus.shipped,
          _OrderListFilter.delivered => order.status == OrderStatus.delivered,
          _OrderListFilter.cancelled => order.status == OrderStatus.cancelled,
        };
      }).length;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          _FilterChipButton(
            label: 'Todos',
            icon: Icons.grid_view_rounded,
            count: countFor(_OrderListFilter.all),
            selected: _filter == _OrderListFilter.all,
            color: palette.primary,
            onTap: () => setState(() => _filter = _OrderListFilter.all),
          ),
          _FilterChipButton(
            label: 'Pendientes',
            icon: Icons.hourglass_bottom_rounded,
            count: countFor(_OrderListFilter.pending),
            selected: _filter == _OrderListFilter.pending,
            color: RoleTheme.iconWarning,
            onTap: () => setState(() => _filter = _OrderListFilter.pending),
          ),
          _FilterChipButton(
            label: 'Confirmados',
            icon: Icons.verified_rounded,
            count: countFor(_OrderListFilter.confirmed),
            selected: _filter == _OrderListFilter.confirmed,
            color: RoleTheme.iconValidation,
            onTap: () => setState(() => _filter = _OrderListFilter.confirmed),
          ),
          _FilterChipButton(
            label: 'Preparando',
            icon: Icons.restaurant_rounded,
            count: countFor(_OrderListFilter.preparing),
            selected: _filter == _OrderListFilter.preparing,
            color: RoleTheme.iconInfo,
            onTap: () => setState(() => _filter = _OrderListFilter.preparing),
          ),
          _FilterChipButton(
            label: 'En camino',
            icon: Icons.delivery_dining_rounded,
            count: countFor(_OrderListFilter.shipped),
            selected: _filter == _OrderListFilter.shipped,
            color: RoleTheme.entrepreneur.secondary,
            onTap: () => setState(() => _filter = _OrderListFilter.shipped),
          ),
          _FilterChipButton(
            label: 'Entregados',
            icon: Icons.check_circle_outline_rounded,
            count: countFor(_OrderListFilter.delivered),
            selected: _filter == _OrderListFilter.delivered,
            color: RoleTheme.iconValidation,
            onTap: () => setState(() => _filter = _OrderListFilter.delivered),
          ),
          _FilterChipButton(
            label: 'Cancelados',
            icon: Icons.cancel_outlined,
            count: countFor(_OrderListFilter.cancelled),
            selected: _filter == _OrderListFilter.cancelled,
            color: RoleTheme.iconDanger,
            onTap: () => setState(() => _filter = _OrderListFilter.cancelled),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredEmpty(RolePalette palette) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 18.h),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, color: palette.primary, size: 34.sp),
          SizedBox(height: 10.h),
          Text(
            'Sin pedidos en este filtro',
            style: TextStyle(
              color: palette.text,
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'Prueba con otro estado o cambia la búsqueda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(RolePalette palette, OrderController controller) {
    final visibleOrders = _visibleOrders(controller.orders);

    return RefreshIndicator(
      color: palette.primary,
      onRefresh: _loadOrders,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 92.h),
        itemCount: visibleOrders.isEmpty ? 4 : visibleOrders.length + 3,
        itemBuilder: (context, index) {
          if (index == 0) return OrdersSummaryHeader(controller: controller);
          if (index == 1) return _buildSearch(palette);
          if (index == 2) return _buildFilterBar(palette, controller.orders);

          if (visibleOrders.isEmpty) return _buildFilteredEmpty(palette);

          final order = visibleOrders[index - 3];
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: OrderListItem(
              key: ValueKey('${order.id}-${order.status.name}'),
              order: order,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageContent(RolePalette palette, OrderController controller) {
    final uiState = _screenController.resolveUiState(controller);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showControllerError(controller);
    });

    switch (uiState) {
      case EntrepreneurOrderListUiState.loading:
        return _buildLoadingState(palette);
      case EntrepreneurOrderListUiState.error:
        return _buildErrorState(controller);
      case EntrepreneurOrderListUiState.empty:
        return _buildEmptyState(palette);
      case EntrepreneurOrderListUiState.content:
        return _buildOrdersList(palette, controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Consumer<OrderController>(
          builder: (context, controller, child) {
            return _buildPageContent(palette, controller);
          },
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.icon,
    required this.count,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 7.w),
      child: InkWell(
        borderRadius: BorderRadius.circular(11.r),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.2.h),
          decoration: BoxDecoration(
            color: selected ? color : Colors.white,
            borderRadius: BorderRadius.circular(11.r),
            border: Border.all(
              color: selected ? color : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12.5.sp, color: selected ? Colors.white : color),
              SizedBox(width: 5.w),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : RoleTheme.entrepreneur.text,
                  fontSize: 10.2.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 5.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.8.h),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.18)
                      : color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected ? Colors.white : color,
                    fontSize: 8.4.sp,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
