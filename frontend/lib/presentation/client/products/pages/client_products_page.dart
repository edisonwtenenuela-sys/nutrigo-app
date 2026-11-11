import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';
import 'package:emprendedor/data/models/shared/order_business_summary.dart';
import 'package:emprendedor/features/client/controllers/client_product_promotion_controller.dart';
import 'package:emprendedor/features/client/controllers/client_products_controller.dart';
import 'package:emprendedor/presentation/client/products/widgets/index.dart';

class ClientProductsPage extends StatefulWidget {
  const ClientProductsPage({super.key});

  @override
  State<ClientProductsPage> createState() => _ClientProductsPageState();
}

class _ClientProductsPageState extends State<ClientProductsPage> {
  final ClientProductsController _controller = ClientProductsController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  AppBar _buildAppBar(RolePalette palette) {
    return AppBar(
      backgroundColor: palette.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Comidas saludables',
        style: TextStyle(
          color: palette.text,
          fontWeight: FontWeight.w900,
          fontSize: 19.sp,
        ),
      ),
    );
  }

  Widget _buildSearchHeader(
    ClientProductsSnapshotViewData viewData, {
    required bool isLoading,
  }) {
    return ClientProductsSearchHeader(
      controller: _controller.searchController,
      searchText: viewData.searchText,
      totalProducts: viewData.allProducts.length,
      visibleProducts: viewData.filteredProducts.length,
      onChanged: _controller.updateSearch,
      onClear: _controller.clearSearch,
      isLoading: isLoading,
    );
  }

  Widget _buildRefreshableProducts({
    required AsyncSnapshot<List<ProductModel>> snapshot,
    required ClientProductsSnapshotViewData viewData,
    required RolePalette palette,
  }) {
    return Expanded(
      child: RefreshIndicator(
        color: RoleTheme.iconHealth,
        onRefresh: _controller.refreshProducts,
        child: _buildProductsState(
          snapshot: snapshot,
          viewData: viewData,
          palette: palette,
        ),
      ),
    );
  }

  Widget _buildPageContent(RolePalette palette) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return StreamBuilder<List<ProductModel>>(
          stream: _controller.approvedProductsStream,
          initialData: _controller.initialApprovedProducts,
          builder: (context, snapshot) {
            final viewData = _controller.buildViewData(snapshot.data ?? []);
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;

            return Column(
              children: [
                _buildSearchHeader(viewData, isLoading: isLoading),
                _buildRefreshableProducts(
                  snapshot: snapshot,
                  viewData: viewData,
                  palette: palette,
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: _buildAppBar(palette),
      body: _buildPageContent(palette),
    );
  }

  Widget _buildProductsState({
    required AsyncSnapshot<List<ProductModel>> snapshot,
    required ClientProductsSnapshotViewData viewData,
    required RolePalette palette,
  }) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(color: RoleTheme.iconHealth),
      );
    }

    if (snapshot.hasError) {
      return ClientProductsEmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'No se pudieron cargar los productos',
        message: 'Revisa tu conexión e intenta actualizar la pantalla.',
        color: RoleTheme.iconDanger,
      );
    }

    if (viewData.allProducts.isEmpty) {
      return const ClientProductsEmptyState(
        icon: Icons.verified_outlined,
        title: 'Sin productos validados',
        message:
            'Cuando los nutricionistas aprueben comidas saludables, aparecerán aquí para que puedas agregarlas a tu carrito.',
        color: RoleTheme.iconHealth,
      );
    }

    if (viewData.filteredProducts.isEmpty) {
      return ClientProductsEmptyState(
        icon: Icons.search_off_rounded,
        title: 'Sin resultados',
        message:
            'No encontramos productos relacionados con "${viewData.searchText}".',
        color: RoleTheme.iconInfo,
        actionLabel: 'Limpiar búsqueda',
        onAction: _controller.clearSearch,
      );
    }

    return StreamBuilder<Map<String, OrderBusinessSummary>>(
      stream: _controller.businessSummariesStreamFor(viewData.allProducts),
      initialData: _controller.cachedBusinessSummariesFor(viewData.allProducts),
      builder: (context, businessSnapshot) {
        final businessSummaries = businessSnapshot.data ?? const {};

        return FutureBuilder<Map<String, ProductPromotionInfo?>>(
          future: _controller.promotionsFor(viewData.allProducts),
          initialData: _controller.cachedPromotionsFor(viewData.allProducts),
          builder: (context, promotionSnapshot) {
            final promotions = promotionSnapshot.data ?? const {};

            return ListView.builder(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
              itemCount: viewData.filteredProducts.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ClientProductsListHeader(
                    count: viewData.filteredProducts.length,
                    isSearching: viewData.hasSearch,
                  );
                }

                final product = viewData.filteredProducts[index - 1];
                final promotionKey = _controller.promotionKeyFor(product);
                final businessSummary = product.userId == null
                    ? null
                    : businessSummaries[product.userId!.trim()];

                return ProductCard(
                  product: product,
                  businessSummary: businessSummary,
                  promotionInfo: promotions[promotionKey],
                  promotionResolved: promotions.containsKey(promotionKey),
                  resolveBusinessIndependently: false,
                  resolvePromotionIndependently: false,
                );
              },
            );
          },
        );
      },
    );
  }
}
