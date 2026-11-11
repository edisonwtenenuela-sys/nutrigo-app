import 'dart:async';

import 'package:flutter/material.dart';

import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';
import 'package:emprendedor/data/models/shared/order_business_summary.dart';
import 'package:emprendedor/data/repositories/shared/order_repository.dart';
import 'package:emprendedor/data/repositories/entrepreneur/catalog/product_repository.dart';
import 'package:emprendedor/features/client/helpers/client_products_search_helper.dart';
import 'package:emprendedor/features/client/controllers/client_product_card_controller.dart';
import 'package:emprendedor/features/client/controllers/client_product_promotion_controller.dart';

class ClientProductsSnapshotViewData {
  const ClientProductsSnapshotViewData({
    required this.allProducts,
    required this.filteredProducts,
    required this.searchText,
  });

  final List<ProductModel> allProducts;
  final List<ProductModel> filteredProducts;
  final String searchText;

  bool get hasSearch => searchText.trim().isNotEmpty;
}

class ClientProductsController extends ChangeNotifier {
  ClientProductsController({
    ProductRepository? repository,
    OrderRepository? orderRepository,
    ClientProductPromotionController? promotionController,
  }) : _repository = repository ?? ProductRepository(),
       _orderRepository = orderRepository ?? OrderRepository(),
       _promotionController =
           promotionController ?? ClientProductPromotionController();

  final ProductRepository _repository;
  final OrderRepository _orderRepository;
  final ClientProductPromotionController _promotionController;
  static List<ProductModel> _approvedProductsCache = const [];
  static bool _hasApprovedProductsCache = false;

  static List<ProductModel> cachedApprovedProductsForBusiness(
    String businessId,
  ) {
    final cleanBusinessId = businessId.trim();
    if (cleanBusinessId.isEmpty || !_hasApprovedProductsCache) return const [];

    return List<ProductModel>.unmodifiable(
      _sortFeaturedFirst(
        _approvedProductsCache
            .where((product) => product.userId?.trim() == cleanBusinessId)
            .toList(),
      ),
    );
  }

  static List<ProductModel> _sortFeaturedFirst(List<ProductModel> products) {
    final sortedProducts = [...products];
    sortedProducts.sort((a, b) {
      if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
      final aDate = a.createdAt;
      final bDate = b.createdAt;
      if (aDate != null && bDate != null) return bDate.compareTo(aDate);
      return 0;
    });
    return sortedProducts;
  }

  static Map<String, ProductPromotionInfo?> cachedPromotionsForProducts(
    List<ProductModel> products,
  ) {
    return {
      for (final product in products)
        if (_promotionCache.containsKey(_promotionCacheKey(product)))
          _promotionCacheKey(product):
              _promotionCache[_promotionCacheKey(product)],
    };
  }

  static String _promotionCacheKey(ProductModel product) {
    final productId = product.id?.trim();
    if (productId != null && productId.isNotEmpty) return productId;
    return '${product.userId?.trim() ?? ''}:${product.name.trim()}';
  }

  static final Map<String, OrderBusinessSummary> _businessSummaryCache = {};
  static final Map<String, ProductPromotionInfo?> _promotionCache = {};
  late final Stream<List<ProductModel>> _approvedProductsStream = _repository
      .getApprovedProducts()
      .map((products) {
        _approvedProductsCache = List<ProductModel>.unmodifiable(products);
        _hasApprovedProductsCache = true;
        return _sortFeaturedFirst(products);
      });
  Future<Map<String, OrderBusinessSummary>>? _businessSummariesFuture;
  Future<Map<String, ProductPromotionInfo?>>? _promotionsFuture;
  String _businessSummariesKey = '';
  String _promotionsKey = '';
  final searchController = TextEditingController();
  Timer? _searchDebounce;

  String _searchText = '';
  String get searchText => _searchText;

  List<ProductModel>? get initialApprovedProducts => _hasApprovedProductsCache
      ? List.unmodifiable(_approvedProductsCache)
      : null;

  Stream<List<ProductModel>> get approvedProductsStream =>
      _approvedProductsStream;

  Future<void> preloadApprovedProducts() async {
    try {
      final products = _hasApprovedProductsCache
          ? _approvedProductsCache
          : await approvedProductsStream.first;
      await Future.wait([
        businessSummariesFor(products),
        promotionsFor(products),
      ]);
    } catch (_) {
      // El catálogo conserva su propio estado de error al abrirse; una falla
      // de precarga no debe bloquear Inicio ni el pull-to-refresh.
    }
  }

  Map<String, OrderBusinessSummary> cachedBusinessSummariesFor(
    List<ProductModel> products,
  ) {
    return {
      for (final product in products)
        if (product.userId?.trim().isNotEmpty == true &&
            _businessSummaryCache.containsKey(product.userId!.trim()))
          product.userId!.trim():
              _businessSummaryCache[product.userId!.trim()]!,
    };
  }

  static void cacheBusinessSummary(
    String businessId,
    OrderBusinessSummary summary,
  ) {
    final cleanBusinessId = businessId.trim();
    if (cleanBusinessId.isEmpty) return;
    if (ClientProductCardController.isGenericBusinessName(summary.name)) return;

    _businessSummaryCache[cleanBusinessId] = summary;
    ClientProductCardController.cacheBusinessSummary(cleanBusinessId, summary);
  }

  static void invalidateBusinessSummary(String businessId) {
    final cleanBusinessId = businessId.trim();
    if (cleanBusinessId.isEmpty) return;
    _businessSummaryCache.remove(cleanBusinessId);
    ClientProductCardController.invalidateBusinessSummary(cleanBusinessId);
  }

  Stream<Map<String, OrderBusinessSummary>> businessSummariesStreamFor(
    List<ProductModel> products,
  ) {
    final businessIds =
        products
            .map((product) => product.userId?.trim())
            .whereType<String>()
            .where((userId) => userId.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return _orderRepository.watchBusinessSummariesForOrders(businessIds).map((
      summaries,
    ) {
      for (final entry in summaries.entries) {
        cacheBusinessSummary(entry.key, entry.value);
      }
      return summaries;
    });
  }

  Map<String, ProductPromotionInfo?> cachedPromotionsFor(
    List<ProductModel> products,
  ) {
    return {
      for (final product in products)
        if (_promotionCache.containsKey(promotionKeyFor(product)))
          promotionKeyFor(product): _promotionCache[promotionKeyFor(product)],
    };
  }

  ClientProductsSnapshotViewData buildViewData(List<ProductModel> products) {
    final sortedProducts = _sortFeaturedFirst(products);
    return ClientProductsSnapshotViewData(
      allProducts: sortedProducts,
      filteredProducts: ClientProductsSearchHelper.filterProducts(
        sortedProducts,
        _searchText,
      ),
      searchText: _searchText,
    );
  }

  Future<Map<String, OrderBusinessSummary>> businessSummariesFor(
    List<ProductModel> products,
  ) {
    final businessIds =
        products
            .map((product) => product.userId?.trim())
            .whereType<String>()
            .where((userId) => userId.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final key = businessIds.join('|');

    if (_businessSummariesFuture != null && _businessSummariesKey == key) {
      return _businessSummariesFuture!;
    }

    _businessSummariesKey = key;
    _businessSummariesFuture = _loadBusinessSummaries(businessIds);
    return _businessSummariesFuture!;
  }

  Future<Map<String, OrderBusinessSummary>> _loadBusinessSummaries(
    List<String> businessIds,
  ) async {
    final missingIds = businessIds
        .where((businessId) => !_businessSummaryCache.containsKey(businessId))
        .toList();

    await Future.wait(
      missingIds.map((businessId) async {
        final summary = await _orderRepository.getBusinessSummaryForOrder(
          businessId,
        );
        if (!ClientProductCardController.isGenericBusinessName(summary.name)) {
          _businessSummaryCache[businessId] = summary;
          ClientProductCardController.cacheBusinessSummary(businessId, summary);
        }
      }),
    );

    return {
      for (final businessId in businessIds)
        if (_businessSummaryCache[businessId] != null)
          businessId: _businessSummaryCache[businessId]!,
    };
  }

  Future<Map<String, ProductPromotionInfo?>> promotionsFor(
    List<ProductModel> products,
  ) {
    final sortedProducts = [...products]
      ..sort((a, b) => promotionKeyFor(a).compareTo(promotionKeyFor(b)));
    final key = sortedProducts.map(promotionKeyFor).join('|');

    if (_promotionsFuture != null && _promotionsKey == key) {
      return _promotionsFuture!;
    }

    _promotionsKey = key;
    _promotionsFuture = _loadPromotions(sortedProducts);
    return _promotionsFuture!;
  }

  Future<Map<String, ProductPromotionInfo?>> _loadPromotions(
    List<ProductModel> products,
  ) async {
    final missingProducts = products
        .where(
          (product) => !_promotionCache.containsKey(promotionKeyFor(product)),
        )
        .toList();

    await Future.wait(
      missingProducts.map((product) async {
        _promotionCache[promotionKeyFor(product)] = await _promotionController
            .getActivePromotionForBusiness(
              product.userId,
              productId: product.id,
            );
      }),
    );

    return {
      for (final product in products)
        promotionKeyFor(product): _promotionCache[promotionKeyFor(product)],
    };
  }

  String promotionKeyFor(ProductModel product) {
    return _promotionCacheKey(product);
  }

  void updateSearch(String value) {
    if (_searchText == value) return;

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 160), () {
      if (_searchText == value) return;
      _searchText = value;
      notifyListeners();
    });
  }

  void clearSearch() {
    if (_searchText.isEmpty && searchController.text.isEmpty) return;

    _searchDebounce?.cancel();
    searchController.clear();
    _searchText = '';
    notifyListeners();
  }

  Future<void> refreshProducts() async {
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }
}
