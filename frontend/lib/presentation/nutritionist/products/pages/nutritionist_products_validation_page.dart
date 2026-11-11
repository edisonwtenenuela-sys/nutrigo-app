import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/business_profile_model.dart';
import 'package:emprendedor/data/repositories/entrepreneur/profile/business_profile_repository.dart';
import 'package:emprendedor/features/entrepreneur/controllers/product_controller.dart';
import 'package:emprendedor/features/nutritionist/controllers/index.dart';
import 'package:emprendedor/presentation/nutritionist/products/dialogs/reject_product_dialog.dart';
import 'package:emprendedor/presentation/nutritionist/products/widgets/index.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class NutritionistProductsValidationPage extends StatefulWidget {
  const NutritionistProductsValidationPage({super.key});

  @override
  State<NutritionistProductsValidationPage> createState() =>
      _NutritionistProductsValidationPageState();
}

class _NutritionistProductsValidationPageState
    extends State<NutritionistProductsValidationPage> {
  final BusinessProfileRepository _businessProfileRepository =
      BusinessProfileRepository();
  final Map<String, BusinessProfileModel?> _businessProfileCache = {};
  late final NutritionistProductValidationController _screenController;

  @override
  void initState() {
    super.initState();
    _screenController = NutritionistProductValidationController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refresh();
    });
  }

  @override
  void dispose() {
    _screenController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await _screenController.loadProducts(context.read<ProductController>());
  }

  Future<void> _showFeedback(NutritionistProductValidationResult result) {
    return showAppMessage(
      context,
      role: AppFeedbackRole.nutritionist,
      type: result.type.toPresentationType(),
      title: result.title,
      message: result.message,
    );
  }

  Future<void> _handleResult(NutritionistProductValidationResult result) async {
    if (!mounted) return;
    await _showFeedback(result);

    if (result.shouldRefresh && mounted) {
      await _refresh();
    }
  }

  Future<void> _approveProduct(
    ProductController controller,
    ProductModel product,
  ) async {
    final result = await _screenController.approveProduct(controller, product);
    await _handleResult(result);
  }

  Future<void> _rejectProduct(
    ProductController controller,
    ProductModel product,
  ) async {
    final preflightResult = await _screenController.prepareProductResolution(
      controller,
      product,
    );
    if (!mounted) return;
    if (preflightResult != null) {
      await _handleResult(preflightResult);
      return;
    }

    final comment = await showRejectProductDialog(context: context);
    if (comment == null) return;

    final result = await _screenController.rejectProduct(
      controller,
      product,
      comment,
    );
    await _handleResult(result);
  }

  void _closeReviewSheetAndRun(
    BuildContext sheetContext,
    Future<void> Function() action,
  ) {
    Navigator.of(sheetContext).maybePop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      action();
    });
  }

  Future<void> _reviewProduct(
    ProductController controller,
    ProductModel product,
  ) async {
    final businessProfile = await _businessProfileFor(product);
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => NutritionistProductValidationDetailSheet(
        product: product,
        isLoading: controller.isLoading,
        isProcessing: _screenController.isProcessing(product),
        initialBusinessProfile: businessProfile,
        onApprove: () => _closeReviewSheetAndRun(
          sheetContext,
          () => _approveProduct(controller, product),
        ),
        onReject: () => _closeReviewSheetAndRun(
          sheetContext,
          () => _rejectProduct(controller, product),
        ),
      ),
    );
  }

  Future<BusinessProfileModel?> _businessProfileFor(
    ProductModel product,
  ) async {
    final businessId = product.userId?.trim();
    if (businessId == null || businessId.isEmpty) return null;

    if (_businessProfileCache.containsKey(businessId)) {
      return _businessProfileCache[businessId];
    }

    final profile = await _businessProfileRepository.getBusinessProfile(
      businessId,
    );
    _businessProfileCache[businessId] = profile;
    return profile;
  }

  Widget _buildScrollableState({required List<Widget> children}) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 18.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(children: children),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusTabs(ProductController controller) {
    return Row(
      children: NutritionistValidationProductFilter.values.map((filter) {
        final selected = _screenController.selectedFilter == filter;
        final count = _screenController.countFor(controller, filter);
        final color = filter.color;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: Material(
              color: selected
                  ? color.withValues(alpha: 0.08)
                  : RoleTheme.brandChipBackground,
              borderRadius: BorderRadius.circular(10.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(10.r),
                onTap: () => _screenController.setFilter(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: selected
                          ? color.withValues(alpha: 0.55)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${filter.label} $count',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSortRow() {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: RoleTheme.brandSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: RoleTheme.brandBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: RoleTheme.brandBadgeBackground,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: RoleTheme.brandPrimary,
              size: 17.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Ordenar productos',
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w900,
                color: RoleTheme.brandText,
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 162.w),
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: RoleTheme.brandSurface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: RoleTheme.brandBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<NutritionistProductValidationSortOption>(
                value: _screenController.sortOption,
                isDense: true,
                isExpanded: true,
                borderRadius: BorderRadius.circular(16.r),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: RoleTheme.brandPrimary,
                  size: 20.sp,
                ),
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: RoleTheme.brandPrimary,
                ),
                items: NutritionistProductValidationSortOption.values
                    .map(
                      (option) => DropdownMenuItem(
                        value: option,
                        child: Text(
                          option.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (option) {
                  if (option == null) return;
                  _screenController.setSortOption(option);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationToolbar(ProductController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(7.w),
      decoration: BoxDecoration(
        color: RoleTheme.brandSurface,
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(color: RoleTheme.brandBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(children: [_buildStatusTabs(controller), _buildSortRow()]),
    );
  }

  ({String title, String description}) _emptyCopy() {
    return switch (_screenController.selectedFilter) {
      NutritionistValidationProductFilter.pending => (
        title: 'Sin productos pendientes',
        description:
            'Cuando un emprendedor envíe un producto a revisión, aparecerá aquí.',
      ),
      NutritionistValidationProductFilter.approved => (
        title: 'Sin productos aprobados',
        description:
            'Los productos aprobados por nutrición aparecerán en este historial.',
      ),
      NutritionistValidationProductFilter.rejected => (
        title: 'Sin productos rechazados',
        description:
            'Los productos rechazados aparecerán aquí con su motivo de corrección.',
      ),
    };
  }

  Widget _buildBody(ProductController controller) {
    final uiState = _screenController.resolveUiState(controller);

    if (uiState == NutritionistProductValidationUiState.loading) {
      return Center(
        child: CircularProgressIndicator(color: RoleTheme.nutritionist.primary),
      );
    }

    if (uiState == NutritionistProductValidationUiState.error) {
      return _buildScrollableState(
        children: [
          NutritionistProductsErrorState(message: controller.errorMessage!),
        ],
      );
    }

    final products = _screenController.visibleProducts(controller);
    final toolbar = _buildValidationToolbar(controller);

    if (uiState == NutritionistProductValidationUiState.empty) {
      final copy = _emptyCopy();
      return _buildScrollableState(
        children: [
          toolbar,
          NutritionistProductsEmptyState(
            title: copy.title,
            description: copy.description,
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 18.h),
        itemCount: products.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return toolbar;

          final product = products[index - 1];

          return NutritionistProductValidationCard(
            product: product,
            isLoading: controller.isLoading,
            isProcessing: _screenController.isProcessing(product),
            onReview: () => _reviewProduct(controller, product),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProductController>();

    return ListenableBuilder(
      listenable: _screenController,
      builder: (context, _) => _buildBody(controller),
    );
  }
}
