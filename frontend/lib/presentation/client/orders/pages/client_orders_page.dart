import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/features/client/controllers/client_order_controller.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/presentation/client/orders/widgets/index.dart';
import 'package:emprendedor/features/auth/controllers/auth_session_controller.dart';

class ClientOrdersPage extends StatefulWidget {
  const ClientOrdersPage({super.key});

  @override
  State<ClientOrdersPage> createState() => _ClientOrdersPageState();
}

class _ClientOrdersPageState extends State<ClientOrdersPage>
    with WidgetsBindingObserver {
  final AuthSessionController _sessionController = AuthSessionController();
  final TextEditingController _searchController = TextEditingController();
  _OrderFilter _selectedFilter = _OrderFilter.all;
  String _searchQuery = '';

  _OrdersUiState _resolveUiState({
    required bool hasUser,
    required bool isLoading,
    required bool hasOrders,
  }) {
    if (!hasUser) return _OrdersUiState.notSignedIn;
    if (isLoading && !hasOrders) return _OrdersUiState.loading;
    if (!hasOrders) return _OrdersUiState.empty;
    return _OrdersUiState.ready;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = _sessionController.currentUserId();

      if (!mounted) return;

      context.read<ClientOrderController>().setUserId(userId);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reload();
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query == _searchQuery) return;

    setState(() => _searchQuery = query);
  }

  Future<void> _reload() async {
    final userId = _sessionController.currentUserId();

    if (userId == null) return;

    final controller = context.read<ClientOrderController>();

    await controller.setUserId(userId);
    await controller.refreshOrders();
  }

  AppBar _buildAppBar(RolePalette palette) {
    return AppBar(
      backgroundColor: palette.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Mis pedidos',
        style: TextStyle(
          color: palette.text,
          fontWeight: FontWeight.w900,
          fontSize: 19.sp,
        ),
      ),
    );
  }

  Widget _buildNotSignedInState(RolePalette palette) {
    return Center(
      child: Text(
        'Debes iniciar sesión',
        style: TextStyle(
          color: palette.text,
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildLoadingState(RolePalette palette) {
    return Center(child: CircularProgressIndicator(color: palette.primary));
  }

  Widget _buildEmptyState(RolePalette palette) {
    return RefreshIndicator(
      onRefresh: _reload,
      color: palette.primary,
      child: const EmptyClientOrdersView(),
    );
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    return orders.where((order) {
      final matchesStatus = switch (_selectedFilter) {
        _OrderFilter.all => true,
        _OrderFilter.pending => order.status == OrderStatus.pending,
        _OrderFilter.confirmed => order.status == OrderStatus.confirmed,
        _OrderFilter.preparing => order.status == OrderStatus.preparing,
        _OrderFilter.shipped => order.status == OrderStatus.shipped,
        _OrderFilter.delivered => order.status == OrderStatus.delivered,
        _OrderFilter.cancelled => order.status == OrderStatus.cancelled,
      };

      if (!matchesStatus) return false;
      if (_searchQuery.isEmpty) return true;

      final productNames = order.items
          .map((item) => item.productName.toLowerCase())
          .join(' ');
      final orderNumber = order.formattedOrderNumber.toLowerCase();
      final address = order.shippingAddress.toLowerCase();

      return productNames.contains(_searchQuery) ||
          orderNumber.contains(_searchQuery) ||
          address.contains(_searchQuery);
    }).toList();
  }

  Widget _buildSearchField(RolePalette palette) {
    return Container(
      height: 38.h,
      margin: EdgeInsets.only(bottom: 13.h),
      padding: EdgeInsets.symmetric(horizontal: 13.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: RoleTheme.brandBorder.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: RoleTheme.iconOrders.withValues(alpha: 0.018),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: RoleTheme.iconColorFor(
              Icons.search_rounded,
              fallback: palette.primary,
            ),
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              cursorColor: palette.primary,
              decoration: InputDecoration(
                hintText: 'Buscar pedido o emprendimiento',
                hintStyle: TextStyle(
                  color: palette.mutedText.withValues(alpha: 0.60),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                color: palette.text,
                fontSize: 11.2.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: _searchController.clear,
              child: Icon(
                Icons.close_rounded,
                color: RoleTheme.iconColorFor(
                  Icons.close_rounded,
                  fallback: palette.mutedText,
                ),
                size: 16.sp,
              ),
            )
          else
            Icon(
              Icons.filter_alt_outlined,
              color: RoleTheme.iconColorFor(
                Icons.filter_alt_outlined,
                fallback: palette.primary,
              ),
              size: 16.sp,
            ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(List<OrderModel> orders, RolePalette palette) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _OrderFilterChip(
              label: 'Todos',
              icon: Icons.receipt_long_rounded,
              selected: _selectedFilter == _OrderFilter.all,
              color: RoleTheme.iconOrders,
              onTap: () => setState(() => _selectedFilter = _OrderFilter.all),
            ),
            SizedBox(width: 6.w),
            _OrderFilterChip(
              label: 'En revisión',
              icon: Icons.hourglass_bottom_rounded,
              selected: _selectedFilter == _OrderFilter.pending,
              color: RoleTheme.iconWarning,
              onTap: () =>
                  setState(() => _selectedFilter = _OrderFilter.pending),
            ),
            SizedBox(width: 6.w),
            _OrderFilterChip(
              label: 'Confirmados',
              icon: Icons.verified_rounded,
              selected: _selectedFilter == _OrderFilter.confirmed,
              color: RoleTheme.iconValidation,
              onTap: () =>
                  setState(() => _selectedFilter = _OrderFilter.confirmed),
            ),
            SizedBox(width: 6.w),
            _OrderFilterChip(
              label: 'Preparando',
              icon: Icons.restaurant_rounded,
              selected: _selectedFilter == _OrderFilter.preparing,
              color: RoleTheme.iconInfo,
              onTap: () =>
                  setState(() => _selectedFilter = _OrderFilter.preparing),
            ),
            SizedBox(width: 6.w),
            _OrderFilterChip(
              label: 'En camino',
              icon: Icons.delivery_dining_rounded,
              selected: _selectedFilter == _OrderFilter.shipped,
              color: palette.secondary,
              onTap: () =>
                  setState(() => _selectedFilter = _OrderFilter.shipped),
            ),
            SizedBox(width: 6.w),
            _OrderFilterChip(
              label: 'Entregados',
              icon: Icons.check_circle_outline_rounded,
              selected: _selectedFilter == _OrderFilter.delivered,
              color: RoleTheme.iconValidation,
              onTap: () =>
                  setState(() => _selectedFilter = _OrderFilter.delivered),
            ),
            SizedBox(width: 6.w),
            _OrderFilterChip(
              label: 'Cancelados',
              icon: Icons.cancel_outlined,
              selected: _selectedFilter == _OrderFilter.cancelled,
              color: RoleTheme.iconDanger,
              onTap: () =>
                  setState(() => _selectedFilter = _OrderFilter.cancelled),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle({
    required int visibleCount,
    required RolePalette palette,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(2.w, 0, 2.w, 9.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Historial de pedidos',
              style: TextStyle(
                color: palette.text,
                fontSize: 15.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: RoleTheme.iconOrders.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Text(
              '$visibleCount',
              style: TextStyle(
                color: RoleTheme.iconOrders,
                fontSize: 11.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredEmptyState(RolePalette palette) {
    return Padding(
      padding: EdgeInsets.only(top: 35.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(22.w, 28.h, 22.w, 30.h),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: RoleTheme.iconInfo.withValues(alpha: 0.06)),
        ),
        child: Column(
          children: [
            Container(
              width: 68.w,
              height: 68.w,
              decoration: BoxDecoration(
                color: RoleTheme.iconInfo.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.manage_search_rounded,
                color: RoleTheme.iconColorFor(
                  Icons.manage_search_rounded,
                  fallback: RoleTheme.iconInfo,
                ),
                size: 30.sp,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'Sin pedidos en este filtro',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.text,
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Prueba con otro estado o limpia la búsqueda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.mutedText,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList({
    required List<OrderModel> orders,
    required DateFormat dateFormat,
    required RolePalette palette,
  }) {
    final filteredOrders = _filterOrders(orders);

    return RefreshIndicator(
      onRefresh: _reload,
      color: palette.primary,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(18.w, 7.h, 18.w, 18.h),
        itemCount: filteredOrders.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchField(palette),
                ClientOrdersOverview(orders: orders),
                _buildFilterBar(orders, palette),
                _buildSectionTitle(
                  visibleCount: filteredOrders.length,
                  palette: palette,
                ),
                if (filteredOrders.isEmpty) _buildFilteredEmptyState(palette),
              ],
            );
          }

          final order = filteredOrders[index - 1];

          return OrderCard(
            order: order,
            formattedDate: dateFormat.format(order.createdAt.toDate()),
          );
        },
      ),
    );
  }

  Widget _buildBody({
    required ClientOrderController controller,
    required RolePalette palette,
    required DateFormat dateFormat,
  }) {
    final orders = controller.orders;
    final currentUserId = _sessionController.currentUserId();
    final uiState = _resolveUiState(
      hasUser: currentUserId != null,
      isLoading: controller.isLoading,
      hasOrders: orders.isNotEmpty,
    );

    switch (uiState) {
      case _OrdersUiState.notSignedIn:
        return _buildNotSignedInState(palette);
      case _OrdersUiState.loading:
        return _buildLoadingState(palette);
      case _OrdersUiState.empty:
        return _buildEmptyState(palette);
      case _OrdersUiState.ready:
        return _buildOrdersList(
          orders: orders,
          dateFormat: dateFormat,
          palette: palette,
        );
    }
  }

  Widget _buildPageBody(RolePalette palette, DateFormat dateFormat) {
    return Consumer<ClientOrderController>(
      builder: (context, controller, child) {
        return _buildBody(
          controller: controller,
          palette: palette,
          dateFormat: dateFormat,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    const palette = RoleTheme.client;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: _buildAppBar(palette),
      body: _buildPageBody(palette, dateFormat),
    );
  }
}

class _OrderFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _OrderFilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final semanticIconColor = RoleTheme.iconColorFor(icon, fallback: color);

    return InkWell(
      borderRadius: BorderRadius.circular(999.r),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: selected ? semanticIconColor : RoleTheme.client.surface,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: semanticIconColor.withValues(alpha: selected ? 0 : 0.18),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: semanticIconColor.withValues(alpha: 0.14),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 10.5.sp,
              color: selected ? Colors.white : semanticIconColor,
            ),
            SizedBox(width: 5.w),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? Colors.white : semanticIconColor,
                fontSize: 8.6.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _OrdersUiState { notSignedIn, loading, empty, ready }

enum _OrderFilter {
  all,
  pending,
  confirmed,
  preparing,
  shipped,
  delivered,
  cancelled,
}
