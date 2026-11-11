import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';
import 'package:emprendedor/data/repositories/entrepreneur/catalog/product_repository.dart';

enum ProductValidationFilter {
  approved,
  pending,
  rejected;

  NutritionValidationStatus get status {
    return switch (this) {
      ProductValidationFilter.approved => NutritionValidationStatus.approved,
      ProductValidationFilter.pending => NutritionValidationStatus.pending,
      ProductValidationFilter.rejected => NutritionValidationStatus.rejected,
    };
  }
}

enum ProductSortOption {
  newest,
  oldest;

  String get label {
    return switch (this) {
      ProductSortOption.newest => 'Más recientes',
      ProductSortOption.oldest => 'Más antiguos',
    };
  }
}

class ProductController extends ChangeNotifier {
  static const _allCategories = 'Todas';

  final Logger _logger = Logger('ProductController');
  final ProductRepository _productRepository = ProductRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProductModel> _allProducts = [];

  List<ProductModel> get allProducts => List.unmodifiable(_allProducts);

  List<ProductModel> get products {
    final filter = _selectedValidationFilter;
    final productsToShow = filter == null
        ? List<ProductModel>.from(_allProducts)
        : _allProducts
              .where((product) => product.validationStatus == filter.status)
              .toList();

    productsToShow.sort((a, b) {
      final aDate = _sortTimestamp(a);
      final bDate = _sortTimestamp(b);

      return switch (_selectedSortOption) {
        ProductSortOption.newest => bDate.compareTo(aDate),
        ProductSortOption.oldest => aDate.compareTo(bDate),
      };
    });

    return productsToShow;
  }

  bool get hasAnyProducts => _allProducts.isNotEmpty;

  int _sortTimestamp(ProductModel product) {
    return product.updatedAt?.millisecondsSinceEpoch ??
        product.createdAt?.millisecondsSinceEpoch ??
        0;
  }

  final List<String> _categories = [
    _allCategories,
    'Ensaladas',
    'Sopas',
    'Bebidas saludables',
    'Platos fitness',
    'Snacks saludables',
    'Postres saludables',
    'Keto',
    'Vegano',
  ];

  List<String> get categories => _categories;

  String _selectedCategory = _allCategories;
  String get selectedCategory => _selectedCategory;

  ProductValidationFilter? _selectedValidationFilter;
  ProductValidationFilter? get selectedValidationFilter =>
      _selectedValidationFilter;

  ProductSortOption _selectedSortOption = ProductSortOption.newest;
  ProductSortOption get selectedSortOption => _selectedSortOption;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasLoadedProducts = false;
  bool get hasLoadedProducts => _hasLoadedProducts;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  File? _selectedImageFile;
  File? get selectedImageFile => _selectedImageFile;

  StreamSubscription<List<ProductModel>>? _allProductsSubscription;
  int _allProductsUpdateVersion = 0;

  String? _userId;
  String? get userId => _userId;

  bool get _hasValidUserId => _userId != null && _userId!.trim().isNotEmpty;

  bool _isVerifiedEntrepreneur = false;
  bool get isVerifiedEntrepreneur => _isVerifiedEntrepreneur;

  Future<void> initUser() async {
    final user = _auth.currentUser;
    await setUserId(user?.uid);
  }

  Future<void> setUserId(String? userId) async {
    if (_userId == userId) return;

    await _cancelProductsSubscription();
    _userId = userId;

    if (_hasValidUserId) {
      await checkEntrepreneurVerification();
      await fetchProducts();
      return;
    }

    _resetForSignedOutUser();
  }

  Future<bool> checkEntrepreneurVerification() async {
    final user = _auth.currentUser;

    if (user == null) {
      _isVerifiedEntrepreneur = false;
      _setError('Usuario no autenticado.');
      return false;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      final role = data?['role']?.toString();
      final isVerified = data?['isVerified'] == true;

      _isVerifiedEntrepreneur = role == 'emprendedor' && isVerified;
      notifyListeners();

      return _isVerifiedEntrepreneur;
    } catch (e, stackTrace) {
      _logger.severe('Error verificando estado del emprendedor', e, stackTrace);
      _isVerifiedEntrepreneur = false;
      _setError('No se pudo verificar el estado de tu cuenta.');
      return false;
    }
  }

  Future<void> reset() async {
    await _cancelProductsSubscription();

    _allProducts = [];
    _selectedImageFile = null;
    _userId = null;
    _selectedCategory = _allCategories;
    _selectedValidationFilter = null;
    _selectedSortOption = ProductSortOption.newest;
    _errorMessage = null;
    _isLoading = false;
    _hasLoadedProducts = false;
    _isVerifiedEntrepreneur = false;

    notifyListeners();
  }

  void setSelectedImage(File? file) {
    _selectedImageFile = file;
    notifyListeners();
  }

  void clearSelectedImage() {
    if (_selectedImageFile == null) return;

    _selectedImageFile = null;
    notifyListeners();
  }

  void clearLoadingState() {
    if (!_isLoading) return;
    _isLoading = false;
    notifyListeners();
  }

  void clearErrorMessage() {
    _setError(null);
  }

  void setActionError(String message) {
    _setError(message);
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) return;

      setSelectedImage(File(pickedFile.path));
    } catch (e, stackTrace) {
      _logger.severe('Error al seleccionar imagen', e, stackTrace);
      _setError('No se pudo seleccionar la imagen.');
    }
  }

  Future<void> fetchProducts({String? category}) async {
    if (!_hasValidUserId) {
      _allProducts = [];
      _setError('Usuario no autenticado. No se pueden cargar productos.');
      _setLoading(false);
      return;
    }

    _prepareFetch();
    await _cancelProductsSubscription();

    final categoryToFetch = category ?? _selectedCategory;

    await _listenToProducts(
      streamFactory: () => _productStreamForCategory(categoryToFetch),
      contextLabel: "la categoría '$categoryToFetch'",
      userErrorPrefix: 'Error al cargar productos',
      delayEmptyWhileLoading: false,
    );
  }

  Future<void> fetchPendingProductsForNutritionist() async {
    _prepareFetch();
    await _cancelProductsSubscription();

    await _listenToProducts(
      streamFactory: _productRepository.getPendingProducts,
      contextLabel: 'productos pendientes de validación',
      userErrorPrefix: 'Error al cargar productos pendientes',
    );
  }

  Future<void> fetchProductsForNutritionistValidation() async {
    _prepareFetch();
    await _cancelProductsSubscription();

    await _listenToProducts(
      streamFactory: _productRepository.getProductsForNutritionistValidation,
      contextLabel: 'productos de validación nutricional',
      userErrorPrefix: 'Error al cargar productos para validar',
      delayEmptyWhileLoading: false,
    );
  }

  Future<void> fetchApprovedProductsForClient({String? category}) async {
    _prepareFetch();
    await _cancelProductsSubscription();

    await _listenToProducts(
      streamFactory: () =>
          category == null || category == _allCategories || category.isEmpty
          ? _productRepository.getApprovedProducts()
          : _productRepository.getApprovedProductsByCategory(category),
      contextLabel: 'productos aprobados',
      userErrorPrefix: 'Error al cargar productos aprobados',
    );
  }

  void setSelectedCategory(String category) {
    if (_selectedCategory == category) return;

    _selectedCategory = category;
    notifyListeners();

    fetchProducts(category: category);
  }

  void toggleValidationFilter(ProductValidationFilter filter) {
    _selectedValidationFilter = _selectedValidationFilter == filter
        ? null
        : filter;
    notifyListeners();
  }

  void setSortOption(ProductSortOption option) {
    if (_selectedSortOption == option) return;

    _selectedSortOption = option;
    notifyListeners();
  }

  Future<bool> addProduct(ProductModel product) async {
    if (!_hasValidUserId) {
      _setError('Usuario no autenticado.');
      return false;
    }

    return _runBoolAction(
      action: () async {
        final productToSave = product.copyWith(
          userId: _userId!,
          status: ProductStatus.unavailable,
          validationStatus: NutritionValidationStatus.pending,
        );

        await _productRepository.addProduct(
          productToSave,
          _selectedImageFile,
          _userId!,
        );

        clearSelectedImage();
      },
      successLog: "Producto '${product.name}' agregado como pendiente.",
      errorLog: 'Error al agregar producto',
      userErrorPrefix: 'Error al agregar producto',
    );
  }

  Future<bool> updateProduct(
    ProductModel product, {
    NutritionValidationStatus? originalValidationStatus,
  }) async {
    if (!_hasValidUserId) {
      _setError('Usuario no autenticado.');
      return false;
    }

    final statusBeforeEdit =
        originalValidationStatus ?? product.validationStatus;
    if (statusBeforeEdit == NutritionValidationStatus.pending) {
      _setError(
        'Este producto está pendiente de validación. Podrás editarlo si el nutricionista solicita correcciones.',
      );
      return false;
    }

    return _runBoolAction(
      action: () async {
        final productToUpdate = product.copyWith(
          validationStatus: NutritionValidationStatus.pending,
          status: ProductStatus.unavailable,
          validationComment: null,
          validatedByNutritionistId: null,
          validatedByNutritionistName: null,
          validatedAt: null,
        );

        await _productRepository.updateProduct(
          productToUpdate,
          _selectedImageFile,
          _userId!,
        );

        if (_selectedImageFile != null) {
          clearSelectedImage();
        }
      },
      successLog:
          "Producto '${product.id} - ${product.name}' actualizado y enviado a revisión.",
      errorLog:
          "Error al actualizar producto '${product.id} - ${product.name}'",
      userErrorPrefix: 'Error al actualizar producto',
    );
  }

  Future<bool> approveProduct({
    required ProductModel product,
    required String nutritionistId,
    required String nutritionistName,
    String? comment,
  }) async {
    return _runBoolAction(
      action: () => _productRepository.updateValidationStatus(
        productId: product.id!,
        validationStatus: NutritionValidationStatus.approved,
        nutritionistId: nutritionistId,
        nutritionistName: nutritionistName,
        comment: comment,
        productStatus: ProductStatus.available,
      ),
      successLog: "Producto '${product.name}' aprobado.",
      errorLog: 'Error al aprobar producto',
      userErrorPrefix: 'Error al aprobar producto',
    );
  }

  Future<bool> canStartValidationAction(ProductModel product) async {
    final productId = product.id?.trim();
    if (productId == null || productId.isEmpty) {
      _setError('No se pudo identificar el producto.');
      return false;
    }

    _setError(null);

    try {
      await _productRepository.verifyProductReachableFromServer(productId);
      return true;
    } catch (e, st) {
      _logger.warning('No se pudo verificar producto antes de validar', e, st);
      _setError('No se pudo validar el producto. ${friendlyErrorMessage(e)}');
      return false;
    }
  }

  Future<bool> rejectProduct({
    required ProductModel product,
    required String nutritionistId,
    required String nutritionistName,
    String? comment,
  }) async {
    return _runBoolAction(
      action: () => _productRepository.updateValidationStatus(
        productId: product.id!,
        validationStatus: NutritionValidationStatus.rejected,
        nutritionistId: nutritionistId,
        nutritionistName: nutritionistName,
        comment: comment,
        productStatus: ProductStatus.unavailable,
      ),
      successLog: "Producto '${product.name}' rechazado.",
      errorLog: 'Error al rechazar producto',
      userErrorPrefix: 'Error al rechazar producto',
    );
  }

  Future<void> toggleFeaturedStatus(String productId, bool newStatus) async {
    if (!_canModifyProduct()) return;

    _setError(null);

    try {
      await _productRepository.updateFeaturedStatus(
        productId,
        newStatus,
        _userId!,
      );

      _logger.info(
        "Estado 'isFeatured' del producto '$productId' cambiado a $newStatus.",
      );
    } catch (e, stackTrace) {
      _logger.severe(
        "Error al cambiar estado 'isFeatured' para el producto '$productId'",
        e,
        stackTrace,
      );
      _setError('No se pudo destacar el producto. ${friendlyErrorMessage(e)}');
    }
  }

  Future<void> deleteProduct(String productId, String? imageUrl) async {
    if (!_canModifyProduct()) return;

    _setLoading(true);
    _setError(null);

    try {
      await _productRepository.deleteProduct(productId, imageUrl, _userId!);
      _logger.info("Producto con ID '$productId' eliminado.");
    } catch (e, stackTrace) {
      _logger.severe('Error al eliminar producto', e, stackTrace);
      _setError('No se pudo eliminar el producto. ${friendlyErrorMessage(e)}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleProductStatus(
    String productId,
    ProductStatus currentStatus,
  ) async {
    if (!_canModifyProduct()) return;

    _setError(null);

    try {
      await _productRepository.toggleProductStatus(
        productId,
        currentStatus,
        _userId!,
      );

      _logger.info("Estado del producto '$productId' cambiado.");
    } catch (e, stackTrace) {
      _logger.severe('Error al cambiar estado del producto', e, stackTrace);
      _setError(
        'No se pudo cambiar el estado del producto. ${friendlyErrorMessage(e)}',
      );
    }
  }

  Stream<List<ProductModel>> _productStreamForCategory(String category) {
    if (category == _allCategories || category.isEmpty) {
      return _productRepository.getProducts(_userId!);
    }

    return _productRepository.getProductsByCategory(_userId!, category);
  }

  bool _canModifyProduct() {
    if (_hasValidUserId) return true;

    _setError('Usuario no autenticado.');
    return false;
  }

  Future<void> _cancelProductsSubscription() async {
    await _allProductsSubscription?.cancel();
    _allProductsSubscription = null;
  }

  Future<void> _listenToProducts({
    required Stream<List<ProductModel>> Function() streamFactory,
    required String contextLabel,
    required String userErrorPrefix,
    bool delayEmptyWhileLoading = true,
  }) async {
    try {
      _allProductsSubscription = streamFactory().listen(
        (productsData) async {
          final updateVersion = ++_allProductsUpdateVersion;

          if (delayEmptyWhileLoading && productsData.isEmpty && _isLoading) {
            _allProducts = [];
            _hasLoadedProducts = false;
            notifyListeners();

            await Future<void>.delayed(const Duration(milliseconds: 900));
            if (updateVersion != _allProductsUpdateVersion) return;
          }

          _allProducts = productsData;
          _hasLoadedProducts = true;
          _setLoading(false);
          notifyListeners();
        },
        onError: (error, stackTrace) {
          _logger.severe('Error al cargar $contextLabel', error, stackTrace);
          _setError('$userErrorPrefix. ${friendlyErrorMessage(error)}');
          _hasLoadedProducts = true;
          _setLoading(false);
        },
      );
    } catch (e, stackTrace) {
      _logger.severe('Excepción al cargar $contextLabel', e, stackTrace);
      _setError('$userErrorPrefix. ${friendlyErrorMessage(e)}');
      _hasLoadedProducts = true;
      _setLoading(false);
    }
  }

  Future<bool> _runBoolAction({
    required Future<void> Function() action,
    required String successLog,
    required String errorLog,
    required String userErrorPrefix,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await action();
      _logger.info(successLog);
      return true;
    } catch (e, stackTrace) {
      _logger.severe(errorLog, e, stackTrace);
      _setError('$userErrorPrefix. ${friendlyErrorMessage(e)}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _prepareFetch() {
    if (!_hasLoadedProducts || _allProducts.isEmpty) {
      _setLoading(true);
    }

    _setError(null);
  }

  void _resetForSignedOutUser() {
    _allProducts = [];
    _selectedImageFile = null;
    _selectedValidationFilter = null;
    _selectedSortOption = ProductSortOption.newest;
    _errorMessage = null;
    _isLoading = false;
    _hasLoadedProducts = false;
    _isVerifiedEntrepreneur = false;

    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;

    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    if (_errorMessage == message) return;

    _errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _allProductsSubscription?.cancel();
    super.dispose();
  }
}
