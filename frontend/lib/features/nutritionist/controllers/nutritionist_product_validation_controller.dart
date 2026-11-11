import 'package:flutter/material.dart';

import 'package:emprendedor/core/services/auth/user_session_service.dart';
import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';
import 'package:emprendedor/data/repositories/nutritionist/nutritionist_profile_repository.dart';
import 'package:emprendedor/features/entrepreneur/controllers/product_controller.dart';
import 'package:emprendedor/core/feedback/app_feedback_level.dart';

enum NutritionistProductValidationUiState { loading, error, empty, ready }

enum NutritionistValidationProductFilter {
  pending,
  approved,
  rejected;

  NutritionValidationStatus get status {
    return switch (this) {
      NutritionistValidationProductFilter.pending =>
        NutritionValidationStatus.pending,
      NutritionistValidationProductFilter.approved =>
        NutritionValidationStatus.approved,
      NutritionistValidationProductFilter.rejected =>
        NutritionValidationStatus.rejected,
    };
  }

  String get label {
    return switch (this) {
      NutritionistValidationProductFilter.pending => 'Pendientes',
      NutritionistValidationProductFilter.approved => 'Aprobados',
      NutritionistValidationProductFilter.rejected => 'Rechazados',
    };
  }

  Color get color {
    return switch (this) {
      NutritionistValidationProductFilter.pending => const Color(0xFFF97316),
      NutritionistValidationProductFilter.approved => const Color(0xFF16A34A),
      NutritionistValidationProductFilter.rejected => const Color(0xFFEF4444),
    };
  }
}

enum NutritionistProductValidationSortOption {
  newest,
  oldest;

  String get label {
    return switch (this) {
      NutritionistProductValidationSortOption.newest => 'Recientes primero',
      NutritionistProductValidationSortOption.oldest => 'Más antiguos primero',
    };
  }
}

class NutritionistProductValidationResult {
  const NutritionistProductValidationResult({
    required this.success,
    required this.type,
    required this.title,
    required this.message,
    this.productId,
    this.shouldRefresh = false,
  });

  final bool success;
  final AppFeedbackLevel type;
  final String title;
  final String message;
  final String? productId;
  final bool shouldRefresh;
}

class NutritionistProductValidationController extends ChangeNotifier {
  NutritionistProductValidationController({
    UserSessionService? sessionService,
    NutritionistProfileRepository? profileRepository,
  }) : _sessionService = sessionService ?? UserSessionService(),
       _profileRepository =
           profileRepository ?? NutritionistProfileRepository();

  final UserSessionService _sessionService;
  final NutritionistProfileRepository _profileRepository;
  final Set<String> _processingProductIds = {};

  NutritionistValidationProductFilter _selectedFilter =
      NutritionistValidationProductFilter.pending;
  NutritionistProductValidationSortOption _sortOption =
      NutritionistProductValidationSortOption.newest;

  Set<String> get processingProductIds => {..._processingProductIds};
  NutritionistValidationProductFilter get selectedFilter => _selectedFilter;
  NutritionistProductValidationSortOption get sortOption => _sortOption;

  void setFilter(NutritionistValidationProductFilter filter) {
    if (_selectedFilter == filter) return;

    _selectedFilter = filter;
    notifyListeners();
  }

  void setSortOption(NutritionistProductValidationSortOption option) {
    if (_sortOption == option) return;

    _sortOption = option;
    notifyListeners();
  }

  int countFor(
    ProductController controller,
    NutritionistValidationProductFilter filter,
  ) {
    return controller.allProducts
        .where((product) => product.validationStatus == filter.status)
        .length;
  }

  List<ProductModel> visibleProducts(ProductController controller) {
    final products = controller.allProducts
        .where((product) => product.validationStatus == _selectedFilter.status)
        .toList();

    products.sort((a, b) {
      final aDate = _sortTimestamp(a);
      final bDate = _sortTimestamp(b);

      return switch (_sortOption) {
        NutritionistProductValidationSortOption.newest => bDate.compareTo(
          aDate,
        ),
        NutritionistProductValidationSortOption.oldest => aDate.compareTo(
          bDate,
        ),
      };
    });

    return products;
  }

  int _sortTimestamp(ProductModel product) {
    return product.validatedAt?.millisecondsSinceEpoch ??
        product.updatedAt?.millisecondsSinceEpoch ??
        product.createdAt?.millisecondsSinceEpoch ??
        0;
  }

  NutritionistProductValidationUiState resolveUiState(
    ProductController controller,
  ) {
    final hasAnyProducts = controller.allProducts.isNotEmpty;
    final hasVisibleProducts = visibleProducts(controller).isNotEmpty;

    if (!controller.hasLoadedProducts && !hasAnyProducts) {
      return NutritionistProductValidationUiState.loading;
    }

    if (controller.isLoading && !hasAnyProducts) {
      return NutritionistProductValidationUiState.loading;
    }

    if (controller.errorMessage != null && !hasAnyProducts) {
      return NutritionistProductValidationUiState.error;
    }

    if (!hasVisibleProducts) {
      return NutritionistProductValidationUiState.empty;
    }

    return NutritionistProductValidationUiState.ready;
  }

  bool isProcessing(ProductModel product) {
    final productId = product.id ?? '';
    return _processingProductIds.contains(productId);
  }

  bool canResolve(ProductModel product) {
    return product.validationStatus == NutritionValidationStatus.pending;
  }

  Future<void> loadProducts(ProductController controller) {
    return controller.fetchProductsForNutritionistValidation();
  }

  Future<NutritionistProductValidationResult> approveProduct(
    ProductController controller,
    ProductModel product,
  ) async {
    final context = _validateContext(product);
    if (context == null) return _invalidContextResult(product.id);

    _setProcessing(context.productId, true);

    final nutritionistName = await _getNutritionistName(context.userId);
    final success = await controller.approveProduct(
      product: product,
      nutritionistId: context.userId,
      nutritionistName: nutritionistName,
      comment: 'Producto validado y aprobado por el nutricionista.',
    );

    _setProcessing(context.productId, false);

    if (success) {
      return NutritionistProductValidationResult(
        success: true,
        type: AppFeedbackLevel.success,
        title: 'Producto validado',
        message: 'Producto aprobado y disponible para los clientes.',
        productId: context.productId,
        shouldRefresh: true,
      );
    }

    return NutritionistProductValidationResult(
      success: false,
      type: AppFeedbackLevel.error,
      title: 'No se pudo validar',
      message: controller.errorMessage ?? 'No se pudo aprobar el producto.',
      productId: context.productId,
    );
  }

  Future<NutritionistProductValidationResult?> prepareProductResolution(
    ProductController controller,
    ProductModel product,
  ) async {
    final context = _validateContext(product);
    if (context == null) return _invalidContextResult(product.id);

    _setProcessing(context.productId, true);
    final canStart = await controller.canStartValidationAction(product);
    _setProcessing(context.productId, false);

    if (canStart) return null;

    return NutritionistProductValidationResult(
      success: false,
      type: AppFeedbackLevel.error,
      title: 'No se pudo validar',
      message:
          controller.errorMessage ??
          'No hay conexión con el servicio. Revisa tu internet e inténtalo nuevamente.',
      productId: context.productId,
    );
  }

  Future<NutritionistProductValidationResult> rejectProduct(
    ProductController controller,
    ProductModel product,
    String comment,
  ) async {
    final trimmedComment = comment.trim();
    if (trimmedComment.isEmpty) {
      return const NutritionistProductValidationResult(
        success: false,
        type: AppFeedbackLevel.error,
        title: 'No se pudo validar',
        message: 'Debes ingresar un motivo de rechazo.',
      );
    }

    final context = _validateContext(product);
    if (context == null) return _invalidContextResult(product.id);

    _setProcessing(context.productId, true);

    final nutritionistName = await _getNutritionistName(context.userId);
    final success = await controller.rejectProduct(
      product: product,
      nutritionistId: context.userId,
      nutritionistName: nutritionistName,
      comment: trimmedComment,
    );

    _setProcessing(context.productId, false);

    if (success) {
      return NutritionistProductValidationResult(
        success: true,
        type: AppFeedbackLevel.warning,
        title: 'Producto rechazado',
        message: 'Producto rechazado. Se notificó al emprendedor.',
        productId: context.productId,
        shouldRefresh: true,
      );
    }

    return NutritionistProductValidationResult(
      success: false,
      type: AppFeedbackLevel.error,
      title: 'No se pudo validar',
      message: controller.errorMessage ?? 'No se pudo rechazar el producto.',
      productId: context.productId,
    );
  }

  _ValidationContext? _validateContext(ProductModel product) {
    final userId = _sessionService.currentUserId();
    final productId = product.id;

    if (userId == null || productId == null || productId.isEmpty) return null;

    return _ValidationContext(userId: userId, productId: productId);
  }

  NutritionistProductValidationResult _invalidContextResult(String? productId) {
    final hasProductId = productId != null && productId.isNotEmpty;
    return NutritionistProductValidationResult(
      success: false,
      type: AppFeedbackLevel.error,
      title: 'No se pudo validar',
      message: hasProductId
          ? 'No hay nutricionista autenticado.'
          : 'No se pudo identificar el producto.',
      productId: productId,
    );
  }

  Future<String> _getNutritionistName(String userId) async {
    final profile = await _profileRepository.getNutritionistProfile(userId);
    final profileName = profile?.name.trim();

    if (profileName != null && profileName.isNotEmpty) return profileName;

    final session = _sessionService.currentSnapshot();
    final displayName = session?.displayName?.trim();

    if (displayName != null && displayName.isNotEmpty) return displayName;

    return 'Nutricionista';
  }

  void _setProcessing(String productId, bool value) {
    if (value) {
      _processingProductIds.add(productId);
    } else {
      _processingProductIds.remove(productId);
    }
    notifyListeners();
  }
}

class _ValidationContext {
  const _ValidationContext({required this.userId, required this.productId});

  final String userId;
  final String productId;
}
