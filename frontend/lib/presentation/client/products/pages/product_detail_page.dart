import 'dart:async';

import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';
import 'package:emprendedor/data/models/shared/cart_item_model.dart';
import 'package:emprendedor/data/models/shared/order_business_summary.dart';
import 'package:emprendedor/data/repositories/entrepreneur/catalog/product_repository.dart';
import 'package:emprendedor/features/client/controllers/cart_controller.dart';
import 'package:emprendedor/features/client/controllers/client_product_card_controller.dart';
import 'package:emprendedor/features/client/controllers/client_product_promotion_controller.dart';
import 'package:emprendedor/presentation/client/cart/pages/cart_page.dart';
import 'package:emprendedor/presentation/client/products/widgets/index.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;
  final ProductPromotionInfo? initialPromotion;
  final bool promotionResolved;
  final OrderBusinessSummary? initialBusinessSummary;

  const ProductDetailPage({
    super.key,
    required this.product,
    this.initialPromotion,
    this.promotionResolved = false,
    this.initialBusinessSummary,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  static final ClientProductCardController _promotionController =
      ClientProductCardController();

  final ProductRepository _productRepository = ProductRepository();
  StreamSubscription<ProductModel?>? _productSubscription;
  late ProductModel _currentProduct;

  ProductModel get product => _currentProduct;
  late final Future<ProductPromotionInfo?> _promotionFuture;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
    _promotionFuture = widget.promotionResolved
        ? SynchronousFuture(widget.initialPromotion)
        : _promotionController.getPromotionForProduct(product);
    _listenToProductChanges();
  }

  void _listenToProductChanges() {
    final productId = widget.product.id?.trim();
    if (productId == null || productId.isEmpty) return;

    _productSubscription = _productRepository.watchProduct(productId).listen((
      updatedProduct,
    ) {
      if (!mounted || updatedProduct == null) return;
      setState(() => _currentProduct = updatedProduct);
    });
  }

  @override
  void dispose() {
    _productSubscription?.cancel();
    super.dispose();
  }

  Widget _vGap(double value) => SizedBox(height: value.h);

  Future<bool> _confirmReplaceCart(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        const palette = RoleTheme.client;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
          ),
          title: Text(
            'Cambiar de negocio',
            style: TextStyle(
              color: palette.text,
              fontWeight: FontWeight.w900,
              fontSize: 17.sp,
            ),
          ),
          content: Text(
            'Tu carrito tiene productos de otro negocio. Para comprar aquí, se vaciará el carrito actual.',
            style: TextStyle(
              color: palette.mutedText,
              fontWeight: FontWeight.w700,
              fontSize: 12.sp,
              height: 1.28,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Vaciar y agregar'),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  Future<void> _addToCart(
    BuildContext context, {
    double? effectivePrice,
    double? originalPrice,
  }) async {
    if (product.id == null) return;

    final cart = context.read<CartController>();

    final cartItem = CartItemModel(
      productId: product.id!,
      name: product.name,
      price: effectivePrice ?? product.price,
      originalPrice: originalPrice,
      imageUrl: product.imageUrl,
      productOwnerId: product.userId,
      approxCalories: product.approxCalories,
      isValidated:
          product.validationStatus == NutritionValidationStatus.approved,
      quantity: 1,
    );

    final replacedCart = cart.hasDifferentBusiness(cartItem);
    if (replacedCart) {
      final shouldReplace = await _confirmReplaceCart(context);
      if (!context.mounted || !shouldReplace) return;
      await cart.replaceCartWithProduct(cartItem);
    } else {
      await cart.addProduct(cartItem);
    }

    if (!context.mounted) return;

    showAppMessage(
      context,
      role: AppFeedbackRole.client,
      type: AppFeedbackType.success,
      title: replacedCart ? 'Carrito actualizado' : 'Producto agregado',
      message: replacedCart
          ? 'Se vació el carrito anterior y se agregó ${product.name}.'
          : '${product.name} se agregó al carrito.',
    );
  }

  List<ProductNutritionFact> get _nutritionFacts {
    return [
      if (product.servingSize?.trim().isNotEmpty == true)
        ProductNutritionFact(
          label: 'Porción',
          value: product.servingSize!.trim(),
          icon: Icons.scale_rounded,
        ),
      if (product.protein != null)
        ProductNutritionFact(
          label: 'Proteínas',
          value: '${product.protein!.toStringAsFixed(0)} g',
          icon: Icons.fitness_center_rounded,
        ),
      if (product.fats != null)
        ProductNutritionFact(
          label: 'Grasas',
          value: '${product.fats!.toStringAsFixed(0)} g',
          icon: Icons.water_drop_rounded,
        ),
      if (product.carbohydrates != null)
        ProductNutritionFact(
          label: 'Carbohidratos',
          value: '${product.carbohydrates!.toStringAsFixed(0)} g',
          icon: Icons.grain_rounded,
        ),
    ];
  }

  bool get _hasNutritionFacts => _nutritionFacts.isNotEmpty;

  int get _nutritionScore {
    var score = 82;
    if (product.validationStatus == NutritionValidationStatus.approved) {
      score += 8;
    }
    if (product.approxCalories != null && product.approxCalories! > 650) {
      score -= 8;
    }
    if (product.allergens.isNotEmpty) {
      score -= 2;
    }
    return score.clamp(0, 100);
  }

  String get _nutritionScoreLabel {
    final score = _nutritionScore;
    if (score >= 85) return 'Excelente';
    if (score >= 70) return 'Buena opción';
    return 'Revisar porción';
  }

  AppBar _buildAppBar(BuildContext context, RolePalette palette) {
    return AppBar(
      backgroundColor: palette.background,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 48.h,
      title: Text(
        'Detalle del producto',
        style: TextStyle(
          color: palette.text,
          fontSize: 18.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
      actions: [
        Selector<CartController, int>(
          selector: (_, cart) => cart.itemCount,
          builder: (context, itemCount, child) {
            return Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    color: palette.text,
                    size: 21.sp,
                  ),
                  onPressed: () => AppNavigator.push(context, const CartPage()),
                ),
                if (itemCount > 0) _buildCartCountBadge(itemCount, palette),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCartCountBadge(int itemCount, RolePalette palette) {
    return Positioned(
      right: 5.w,
      top: 6.h,
      child: Container(
        padding: EdgeInsets.all(4.w),
        constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.w),
        decoration: BoxDecoration(
          color: RoleTheme.iconCart,
          shape: BoxShape.circle,
        ),
        child: Text(
          itemCount.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionScoreCard(RolePalette palette) {
    final score = _nutritionScore;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            RoleTheme.iconValidation.withValues(alpha: 0.08),
            RoleTheme.brandSurface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: RoleTheme.iconValidation.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: RoleTheme.iconValidation.withValues(alpha: 0.06),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: RoleTheme.iconValidation.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.health_and_safety_rounded,
                  color: RoleTheme.iconValidation,
                  size: 19.sp,
                ),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Puntaje estimado',
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 12.4.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Basado en datos declarados y validación profesional.',
                      style: TextStyle(
                        color: palette.mutedText,
                        fontSize: 10.2.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: RoleTheme.iconValidation.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  _nutritionScoreLabel,
                  style: TextStyle(
                    color: RoleTheme.iconValidation,
                    fontSize: 10.6.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$score',
                      style: TextStyle(
                        color: RoleTheme.iconValidation,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    TextSpan(
                      text: '/100',
                      style: TextStyle(
                        color: palette.mutedText,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 5.h),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99.r),
                    child: LinearProgressIndicator(
                      value: score / 100,
                      minHeight: 8.h,
                      backgroundColor: RoleTheme.brandBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        RoleTheme.iconValidation,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(13.r),
              border: Border.all(
                color: RoleTheme.iconValidation.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: RoleTheme.iconValidation,
                  size: 15.sp,
                ),
                SizedBox(width: 7.w),
                Expanded(
                  child: Text(
                    'No reemplaza una evaluación médica individual.',
                    style: TextStyle(
                      color: palette.mutedText,
                      fontSize: 10.2.sp,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergenAlert(RolePalette palette) {
    if (product.allergens.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: RoleTheme.iconWarning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: RoleTheme.iconWarning.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: RoleTheme.iconWarning,
            size: 22.sp,
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alérgenos',
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Contiene: ${product.allergens.join(', ')}.',
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 10.5.sp,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<ProductPromotionInfo?> _getPromotionInfo() {
    return _promotionFuture;
  }

  Widget _buildCouponSection() {
    return FutureBuilder<ProductPromotionInfo?>(
      future: _getPromotionInfo(),
      builder: (context, snapshot) {
        final promotionInfo = snapshot.data;
        final couponCode = promotionInfo?.coupon?.code.trim();
        if (couponCode == null || couponCode.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.only(top: 14.h),
          child: CouponAvailableCard(
            couponCode: couponCode,
            discountLabel: promotionInfo?.availabilityLabel ?? '',
          ),
        );
      },
    );
  }

  Widget _buildScrollableContent(RolePalette palette) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductDetailHeroBlock(
            product: product,
            initialBusinessSummary: widget.initialBusinessSummary,
          ),
          _buildCouponSection(),
          _vGap(14),
          _buildNutritionScoreCard(palette),
          if (_hasNutritionFacts) ...[
            _vGap(14),
            Text(
              product.servingSize?.trim().isNotEmpty == true
                  ? 'Distribución nutricional por ${product.servingSize!.trim()}'
                  : 'Distribución nutricional por porción',
              style: TextStyle(
                color: palette.text,
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            _vGap(8),
            ProductNutritionGrid(facts: _nutritionFacts),
          ],
          _vGap(14),
          _buildAllergenAlert(palette),
          _vGap(14),
          ProductDetailSection(
            title: 'Descripción',
            icon: Icons.article_rounded,
            child: Text(
              product.description.isNotEmpty
                  ? product.description
                  : 'Sin descripción registrada.',
              style: TextStyle(
                color: palette.mutedText,
                height: 1.35,
                fontSize: 12.2.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ..._buildChipSection(
            title: 'Ingredientes (${product.ingredients.length})',
            icon: Icons.restaurant_rounded,
            items: product.ingredients,
          ),
          ..._buildChipSection(
            title: 'Etiquetas dietarias',
            icon: Icons.spa_rounded,
            items: product.dietaryTags,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChipSection({
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    if (items.isEmpty) return const [];

    return [
      _vGap(12),
      ProductDetailSection(
        title: title,
        icon: icon,
        child: Wrap(
          spacing: 7.w,
          runSpacing: 7.h,
          children: items.map((item) => ProductTextChip(label: item)).toList(),
        ),
      ),
    ];
  }

  Widget _buildPageBody(BuildContext context, RolePalette palette) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(child: _buildScrollableContent(palette)),
          FutureBuilder<ProductPromotionInfo?>(
            future: _getPromotionInfo(),
            builder: (context, snapshot) {
              final promotionInfo = snapshot.data;
              final canApplyDiscount =
                  promotionInfo?.isDiscountAvailableFor(product.price) ?? false;
              final effectivePrice = canApplyDiscount
                  ? promotionInfo!.finalPrice(product.price)
                  : product.price;
              final hasDiscount =
                  canApplyDiscount && effectivePrice < product.price;
              final isResolvingPromotion =
                  snapshot.connectionState == ConnectionState.waiting &&
                  promotionInfo == null;

              return ProductBottomActionBar(
                enabled: product.id != null && !isResolvingPromotion,
                price: effectivePrice,
                originalPrice: hasDiscount ? product.price : null,
                onAddToCart: () => _addToCart(
                  context,
                  effectivePrice: effectivePrice,
                  originalPrice: hasDiscount ? product.price : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: _buildAppBar(context, palette),
      body: _buildPageBody(context, palette),
    );
  }
}
