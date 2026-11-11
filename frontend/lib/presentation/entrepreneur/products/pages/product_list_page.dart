import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';
import 'package:emprendedor/presentation/entrepreneur/products/pages/product_form_page.dart';
import 'package:emprendedor/presentation/entrepreneur/products/widgets/index.dart';
import 'package:emprendedor/presentation/shared/widgets/common/app_error_state.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductController>().initUser();
    });
  }

  Future<void> _refreshProducts() async {
    await context.read<ProductController>().initUser();
  }

  void _goToProductForm() {
    AppNavigator.push(context, const ProductFormPage());
  }

  Widget _buildLoadingBar(RolePalette palette) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99.r),
        child: LinearProgressIndicator(
          minHeight: 3,
          color: palette.primary,
          backgroundColor: palette.primary.withValues(alpha: 0.08),
        ),
      ),
    );
  }

  Widget _buildErrorState(ProductController controller) {
    return AppErrorState(
      message: 'Error al cargar productos:\n${controller.errorMessage}',
      onRetry: _refreshProducts,
    );
  }

  Widget _buildEmptyState(RolePalette palette, ProductController controller) {
    final emptyState = ProductsEmptyState(
      selectedCategory: controller.selectedCategory,
      hasProducts: controller.hasAnyProducts,
      onCreateProduct: _goToProductForm,
    );

    if (!controller.hasAnyProducts) {
      return RefreshIndicator(
        color: palette.primary,
        onRefresh: _refreshProducts,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 22.h, 14.w, 96.h),
          children: [emptyState],
        ),
      );
    }

    return RefreshIndicator(
      color: palette.primary,
      onRefresh: _refreshProducts,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 96.h),
            children: [
              SizedBox(
                height: constraints.maxHeight - 96.h,
                child: Center(child: IntrinsicHeight(child: emptyState)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductsList(RolePalette palette, ProductController controller) {
    return RefreshIndicator(
      color: palette.primary,
      onRefresh: _refreshProducts,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 88.h),
        itemCount: controller.products.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return ProductListSummary(
              count: controller.products.length,
              category: controller.selectedCategory,
              selectedFilter: controller.selectedValidationFilter,
              sortOption: controller.selectedSortOption,
              onSortOptionChanged: controller.setSortOption,
              onAddProduct: _goToProductForm,
            );
          }

          final product = controller.products[index - 1];
          return ProductListItem(product: product);
        },
      ),
    );
  }

  Widget _buildContent(RolePalette palette, ProductController controller) {
    if (!controller.hasLoadedProducts && controller.products.isEmpty) {
      return Center(child: CircularProgressIndicator(color: palette.primary));
    }

    final uiState = ProductListController.resolveUiState(controller);

    switch (uiState) {
      case ProductListUiState.error:
        return _buildErrorState(controller);
      case ProductListUiState.empty:
        return _buildEmptyState(palette, controller);
      case ProductListUiState.content:
        return _buildProductsList(palette, controller);
    }
  }

  Widget _buildFab(RolePalette palette) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h, right: 16.w),
      child: Tooltip(
        message: 'Agregar producto',
        child: Material(
          color: palette.primary,
          borderRadius: BorderRadius.circular(12.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: _goToProductForm,
            child: SizedBox(
              width: 34.w,
              height: 34.w,
              child: Icon(Icons.add_rounded, color: Colors.white, size: 18.sp),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageBody(RolePalette palette, ProductController controller) {
    return SafeArea(
      top: false,
      child: Stack(
        children: [
          Column(
            children: [
              ProductsTopHeader(controller: controller),
              if (controller.isLoading) _buildLoadingBar(palette),
              Expanded(child: _buildContent(palette, controller)),
            ],
          ),
          if (controller.hasAnyProducts)
            Positioned(right: 0, bottom: 0, child: _buildFab(palette)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Consumer<ProductController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: palette.background,
          body: _buildPageBody(palette, controller),
        );
      },
    );
  }
}








