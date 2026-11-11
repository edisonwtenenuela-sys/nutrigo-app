import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/services/external_url_launcher_service.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/business_profile_model.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/social_media_model.dart';
import 'package:emprendedor/data/models/shared/order_business_summary.dart';
import 'package:emprendedor/data/repositories/entrepreneur/catalog/product_repository.dart';
import 'package:emprendedor/data/repositories/entrepreneur/profile/business_profile_repository.dart';
import 'package:emprendedor/data/repositories/entrepreneur/profile/social_media_repository.dart';
import 'package:emprendedor/data/repositories/shared/order_repository.dart';
import 'package:emprendedor/features/client/controllers/client_product_promotion_controller.dart';
import 'package:emprendedor/presentation/client/products/pages/product_detail_page.dart';
import 'package:emprendedor/presentation/client/products/widgets/business_store/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BusinessStorePage extends StatefulWidget {
  final String businessId;
  final OrderBusinessSummary? initialSummary;
  final List<ProductModel> initialProducts;
  final Map<String, ProductPromotionInfo?> initialPromotions;
  final ProductModel? highlightedProduct;
  final ProductPromotionInfo? highlightedPromotion;
  final bool highlightedPromotionResolved;

  const BusinessStorePage({
    super.key,
    required this.businessId,
    this.initialSummary,
    this.initialProducts = const [],
    this.initialPromotions = const {},
    this.highlightedProduct,
    this.highlightedPromotion,
    this.highlightedPromotionResolved = false,
  });

  @override
  State<BusinessStorePage> createState() => _BusinessStorePageState();
}

class _BusinessStorePageState extends State<BusinessStorePage> {
  final ProductRepository _productRepository = ProductRepository();
  final OrderRepository _orderRepository = OrderRepository();
  final BusinessProfileRepository _businessProfileRepository =
      BusinessProfileRepository();
  final SocialMediaRepository _socialMediaRepository = SocialMediaRepository();
  final ExternalUrlLauncherService _urlLauncher =
      const ExternalUrlLauncherService();
  final ClientProductPromotionController _promotionController =
      ClientProductPromotionController();

  late final Stream<OrderBusinessSummary> _summaryStream;
  late final Stream<BusinessProfileModel?> _businessProfileStream;
  late final Stream<List<SocialMediaModel>> _socialMediaStream;
  Future<Map<String, ProductPromotionInfo?>>? _promotionsFuture;
  String _promotionsKey = '';

  @override
  void initState() {
    super.initState();
    _summaryStream = _orderRepository.watchBusinessSummaryForOrder(
      widget.businessId,
    );
    _businessProfileStream = _businessProfileRepository.watchBusinessProfile(
      widget.businessId,
    );
    _socialMediaStream = _socialMediaRepository.getSocialMediaLinks(
      widget.businessId,
    );
  }

  AppBar _buildAppBar(RolePalette palette) {
    return AppBar(
      backgroundColor: palette.background,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 48.h,
      title: Text(
        'Tienda',
        style: TextStyle(
          color: palette.text,
          fontSize: 18.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  List<String> _openingHourChips(String openingHours) {
    final value = openingHours.trim();
    if (value.isEmpty) return const [];

    final parts = value
        .split(RegExp(r'\s*(?:\r?\n|;|\|)\s*'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length <= 1) return [value];
    return parts.take(3).toList();
  }

  String _reviewsText(OrderBusinessSummary summary) {
    if (summary.totalReviews <= 0) return 'sin reseñas';
    final label = summary.totalReviews == 1 ? 'reseña' : 'reseñas';
    return '${summary.rating.toStringAsFixed(1)} (${summary.totalReviews}) $label';
  }

  String _visibleBusinessName(String name) {
    final normalized = name.trim();
    if (normalized.isEmpty || normalized.toLowerCase() == 'emprendedor') {
      return 'Negocio saludable';
    }
    return normalized;
  }

  List<ProductModel> _prioritizeHighlighted(List<ProductModel> products) {
    final featuredFirst = [...products]
      ..sort((a, b) {
        if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
        final aDate = a.createdAt;
        final bDate = b.createdAt;
        if (aDate != null && bDate != null) return bDate.compareTo(aDate);
        return 0;
      });

    final highlightedId = widget.highlightedProduct?.id;
    if (highlightedId == null || highlightedId.isEmpty) return featuredFirst;

    final copy = [...featuredFirst];
    final index = copy.indexWhere((product) => product.id == highlightedId);
    if (index <= 0) return copy;

    final highlighted = copy.removeAt(index);
    return [highlighted, ...copy];
  }

  List<MapEntry<SocialMediaType, String>> _visibleSocialLinks({
    required BusinessProfileModel? profile,
    required List<SocialMediaModel> socialMediaLinks,
  }) {
    final linksByType = <SocialMediaType, String>{};

    for (final entry
        in profile?.socialMediaLinks.entries ??
            const Iterable<MapEntry<String, String>>.empty()) {
      final value = entry.value.trim();
      if (value.isEmpty) continue;
      linksByType[stringToSocialMediaType(entry.key)] = value;
    }

    for (final link in socialMediaLinks) {
      final value = link.url.trim();
      if (value.isEmpty) continue;
      linksByType[link.type] = value;
    }

    return linksByType.entries
        .where((entry) => entry.value.trim().isNotEmpty)
        .take(5)
        .toList();
  }

  Future<Map<String, ProductPromotionInfo?>> _promotionsFor(
    List<ProductModel> products,
  ) {
    final sortedProducts = [...products]
      ..sort((a, b) => _productKey(a).compareTo(_productKey(b)));
    final key = sortedProducts.map(_productKey).join('|');

    if (_promotionsFuture != null && _promotionsKey == key) {
      return _promotionsFuture!;
    }

    _promotionsKey = key;
    _promotionsFuture =
        Future.wait(
          sortedProducts.map((product) async {
            final promotion = await _promotionController
                .getActivePromotionForBusiness(
                  product.userId,
                  productId: product.id,
                );
            return MapEntry(_productKey(product), promotion);
          }),
        ).then(
          (entries) => Map<String, ProductPromotionInfo?>.fromEntries(entries),
        );
    return _promotionsFuture!;
  }

  String _productKey(ProductModel product) {
    final productId = product.id?.trim();
    if (productId != null && productId.isNotEmpty) return productId;

    return '${product.userId?.trim() ?? ''}:${product.name.trim()}';
  }

  Map<String, ProductPromotionInfo?> get _initialPromotions {
    final promotions = Map<String, ProductPromotionInfo?>.from(
      widget.initialPromotions,
    );
    final product = widget.highlightedProduct;
    if (product == null || !widget.highlightedPromotionResolved) {
      return promotions;
    }
    promotions[_productKey(product)] = widget.highlightedPromotion;
    return promotions;
  }

  Widget _buildProductsList(
    List<ProductModel> products,
    OrderBusinessSummary summary,
    Map<String, ProductPromotionInfo?> promotions, {
    required Set<String> resolvedPromotionKeys,
  }) {
    final visibleProducts = _prioritizeHighlighted(products);

    if (visibleProducts.isEmpty) {
      return const BusinessStoreEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Row(
            children: [
              Text(
                'Productos de esta tienda',
                style: TextStyle(
                  color: RoleTheme.client.text,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: RoleTheme.iconHealth.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  '${visibleProducts.length}',
                  style: TextStyle(
                    color: RoleTheme.iconHealth,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        ...visibleProducts.map(
          (product) => BusinessStoreProductTile(
            product: product,
            promotionInfo: promotions[_productKey(product)],
            isPromotionLoading: !resolvedPromotionKeys.contains(
              _productKey(product),
            ),
            onTap: () {
              final promotionKey = _productKey(product);
              AppNavigator.push(
                context,
                ProductDetailPage(
                  product: product,
                  initialPromotion: promotions[promotionKey],
                  promotionResolved: resolvedPromotionKeys.contains(
                    promotionKey,
                  ),
                  initialBusinessSummary: summary,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return StreamBuilder<OrderBusinessSummary>(
      stream: _summaryStream,
      initialData: widget.initialSummary,
      builder: (context, summarySnapshot) {
        final summary = summarySnapshot.data ?? OrderBusinessSummary.fallback;
        final isSummaryLoading =
            summarySnapshot.connectionState == ConnectionState.waiting &&
            !summarySnapshot.hasData;

        return StreamBuilder<BusinessProfileModel?>(
          stream: _businessProfileStream,
          builder: (context, profileSnapshot) {
            final profile = profileSnapshot.data;

            return StreamBuilder<List<ProductModel>>(
              stream: _productRepository.getApprovedProductsByBusiness(
                widget.businessId,
              ),
              initialData: widget.initialProducts.isEmpty
                  ? null
                  : widget.initialProducts,
              builder: (context, productsSnapshot) {
                final isProductsLoading =
                    productsSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    !productsSnapshot.hasData;
                final products =
                    productsSnapshot.data ?? const <ProductModel>[];

                if (isSummaryLoading || isProductsLoading) {
                  return const BusinessStoreLoading();
                }

                return StreamBuilder<List<SocialMediaModel>>(
                  stream: _socialMediaStream,
                  initialData: const <SocialMediaModel>[],
                  builder: (context, socialSnapshot) {
                    final socialLinks = _visibleSocialLinks(
                      profile: profile,
                      socialMediaLinks:
                          socialSnapshot.data ?? const <SocialMediaModel>[],
                    );

                    return FutureBuilder<Map<String, ProductPromotionInfo?>>(
                      future: _promotionsFor(products),
                      initialData: _initialPromotions,
                      builder: (context, promotionSnapshot) {
                        final promotions = promotionSnapshot.data ?? const {};

                        return SafeArea(
                          child: CustomScrollView(
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  16.w,
                                  6.h,
                                  16.w,
                                  18.h,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      BusinessStoreHeader(
                                        summary: summary,
                                        businessId: widget.businessId,
                                        products: products,
                                        profile: profile,
                                        visibleBusinessName:
                                            _visibleBusinessName,
                                        openingHourChips: _openingHourChips,
                                        reviewsText: _reviewsText,
                                        socialLinks: socialLinks,
                                        launcher: _urlLauncher,
                                      ),
                                      SizedBox(height: 18.h),
                                      _buildProductsList(
                                        products,
                                        summary,
                                        promotions,
                                        resolvedPromotionKeys: promotions.keys
                                            .toSet(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
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
      body: _buildContent(),
    );
  }
}
