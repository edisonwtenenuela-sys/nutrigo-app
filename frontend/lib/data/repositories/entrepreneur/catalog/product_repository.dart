import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/core/constants/app_constants.dart';
import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Logger _logger = Logger('ProductRepository');

  CollectionReference<Map<String, dynamic>> get _productsCollection =>
      _firestore.collection(AppConstants.productsCollection);

  int _sortByCreatedAtDesc(ProductModel a, ProductModel b) {
    final aDate = a.createdAt ?? Timestamp(0, 0);
    final bDate = b.createdAt ?? Timestamp(0, 0);
    return bDate.compareTo(aDate);
  }

  Stream<List<ProductModel>> getProducts(String userId) {
    return _queryProducts(
      query: _productsCollection.where('userId', isEqualTo: userId),
    );
  }

  Stream<List<ProductModel>> getProductsByCategory(
    String userId,
    String category,
  ) {
    if (_isAllCategory(category)) return getProducts(userId);

    return _queryProducts(
      query: _productsCollection
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category),
    );
  }

  Stream<List<ProductModel>> getPendingProducts() {
    return _queryProducts(
      query: _productsCollection.where(
        'validationStatus',
        isEqualTo: NutritionValidationStatus.pending.value,
      ),
    );
  }

  Stream<List<ProductModel>> getProductsForNutritionistValidation() {
    return _queryProducts(
      query: _productsCollection.where(
        'validationStatus',
        whereIn: NutritionValidationStatus.values
            .map((status) => status.value)
            .toList(),
      ),
    );
  }

  Stream<List<ProductModel>> getApprovedProducts() {
    return _queryProducts(query: _approvedProductsQuery());
  }

  Stream<List<ProductModel>> getApprovedProductsByBusiness(String userId) {
    return _queryProducts(
      query: _approvedProductsQuery().where('userId', isEqualTo: userId),
    );
  }

  Stream<List<ProductModel>> getApprovedProductsByCategory(String category) {
    if (_isAllCategory(category)) return getApprovedProducts();

    return _queryProducts(
      query: _approvedProductsQuery().where('category', isEqualTo: category),
    );
  }

  Stream<ProductModel?> watchProduct(String productId) {
    final cleanProductId = productId.trim();
    if (cleanProductId.isEmpty) return Stream<ProductModel?>.value(null);

    return _productsCollection.doc(cleanProductId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ProductModel.fromFirestore(doc);
    });
  }

  Future<void> verifyProductReachableFromServer(String productId) async {
    final cleanProductId = productId.trim();
    if (cleanProductId.isEmpty) {
      throw Exception('Producto inválido.');
    }

    final doc = await _productsCollection
        .doc(cleanProductId)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 8));

    if (!doc.exists) {
      throw Exception('Producto no encontrado.');
    }
  }

  Stream<List<ProductModel>> getAvailableProductsForClients() {
    return getApprovedProducts();
  }

  Stream<List<ProductModel>> getAvailableProductsByCategoryForClients(
    String category,
  ) {
    return getApprovedProductsByCategory(category);
  }

  Future<List<ProductModel>> getProductsByIds(
    List<String> productIds,
    String userId,
  ) async {
    if (productIds.isEmpty) return [];

    try {
      final cleanIds = productIds
          .map((id) => id.trim())
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      if (cleanIds.isEmpty) return [];

      final snapshot = await _productsCollection
          .where('userId', isEqualTo: userId)
          .get();

      final requestedIds = cleanIds.toSet();
      final products = snapshot.docs
          .where((doc) => requestedIds.contains(doc.id))
          .map(ProductModel.fromFirestore)
          .toList();

      final productsById = {
        for (final product in products) product.id: product,
      };
      return cleanIds
          .map((id) => productsById[id])
          .whereType<ProductModel>()
          .toList();
    } catch (e, st) {
      _logger.severe('Error obteniendo productos por IDs', e, st);
      rethrow;
    }
  }

  Future<List<String>> getCategories(String userId) async {
    try {
      final snapshot = await _productsCollection
          .where('userId', isEqualTo: userId)
          .get();
      return _extractCategories(snapshot.docs);
    } catch (e, st) {
      _logger.severe('Error obteniendo categorías', e, st);
      return ['Todas'];
    }
  }

  Future<List<String>> getAvailableCategoriesForClients() async {
    try {
      final snapshot = await _approvedProductsQuery().get();
      return _extractCategories(snapshot.docs);
    } catch (e, st) {
      _logger.severe(
        'Error obteniendo categorías disponibles para clientes',
        e,
        st,
      );
      return ['Todas'];
    }
  }

  Future<void> addProduct(
    ProductModel product,
    File? imageFile,
    String userId,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 10));

      final imageUrl = imageFile != null
          ? await _uploadProductImage(imageFile, userId)
          : null;
      final productToSave = product.copyWith(
        imageUrl: imageUrl ?? product.imageUrl,
        userId: userId,
        status: ProductStatus.unavailable,
        validationStatus: NutritionValidationStatus.pending,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await _productsCollection
          .add(productToSave.toFirestore())
          .timeout(const Duration(seconds: 12));
      _logger.info('Producto "${product.name}" agregado como pendiente.');
    } catch (e, st) {
      _logger.severe('Error agregando producto', e, st);
      rethrow;
    }
  }

  Future<void> updateProduct(
    ProductModel product,
    File? imageFile,
    String userId,
  ) async {
    try {
      if (product.id == null || product.id!.trim().isEmpty) {
        throw Exception('El producto no tiene ID.');
      }

      final docRef = _productsCollection.doc(product.id);
      final doc = await docRef
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 10));
      _ensureOwner(
        doc,
        userId,
        unauthorizedMessage:
            'No está autorizado para actualizar este producto.',
      );

      var imageUrl = product.imageUrl;
      if (imageFile != null) {
        if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
          await _deleteImageByUrl(product.imageUrl!);
        }
        imageUrl = await _uploadProductImage(imageFile, userId);
      }

      final updated = product.copyWith(
        imageUrl: imageUrl,
        userId: userId,
        status: ProductStatus.unavailable,
        validationStatus: NutritionValidationStatus.pending,
        validatedByNutritionistId: null,
        validatedByNutritionistName: null,
        validationComment: null,
        validatedAt: null,
        updatedAt: Timestamp.now(),
      );

      await docRef
          .set(updated.toFirestore(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 12));
      _logger.info(
        'Producto "${product.name}" actualizado y enviado a revisión.',
      );
    } catch (e, st) {
      _logger.severe('Error actualizando producto', e, st);
      rethrow;
    }
  }

  Future<void> updateValidationStatus({
    required String productId,
    required NutritionValidationStatus validationStatus,
    required String nutritionistId,
    required String nutritionistName,
    String? comment,
    required ProductStatus productStatus,
  }) async {
    try {
      final docRef = _productsCollection.doc(productId);
      final doc = await docRef
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 10));

      if (!doc.exists) {
        throw Exception('Producto no encontrado.');
      }

      await _productsCollection
          .doc(productId)
          .update({
            'validationStatus': validationStatus.value,
            'status': productStatus.name,
            'validatedByNutritionistId': nutritionistId,
            'validatedByNutritionistName': nutritionistName,
            'validationComment': comment,
            'validatedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 12));
    } catch (e, st) {
      _logger.severe('Error validando producto', e, st);
      rethrow;
    }
  }

  Future<void> updateFeaturedStatus(
    String productId,
    bool isFeatured,
    String userId,
  ) async {
    try {
      final docRef = _productsCollection.doc(productId);
      final doc = await docRef
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 10));
      _ensureOwner(
        doc,
        userId,
        unauthorizedMessage:
            'No está autorizado para actualizar este producto.',
      );

      await docRef
          .update({'isFeatured': isFeatured})
          .timeout(const Duration(seconds: 12));
    } catch (e, st) {
      _logger.severe('Error actualizando producto destacado', e, st);
      rethrow;
    }
  }

  Future<void> toggleProductStatus(
    String productId,
    ProductStatus currentStatus,
    String userId,
  ) async {
    try {
      final docRef = _productsCollection.doc(productId);
      final doc = await docRef
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 10));
      _ensureOwner(
        doc,
        userId,
        unauthorizedMessage:
            'No está autorizado para cambiar el estado de este producto.',
      );

      final data = doc.data() ?? {};
      final validationStatus = data['validationStatus']?.toString();
      if (validationStatus != NutritionValidationStatus.approved.value) {
        throw Exception(
          'El producto debe estar aprobado por un nutricionista antes de estar disponible.',
        );
      }

      final newStatus = currentStatus == ProductStatus.available
          ? ProductStatus.unavailable
          : ProductStatus.available;

      await docRef
          .update({'status': newStatus.name})
          .timeout(const Duration(seconds: 12));
    } catch (e, st) {
      _logger.severe('Error cambiando estado del producto', e, st);
      rethrow;
    }
  }

  Future<void> deleteProduct(
    String productId,
    String? imageUrl,
    String userId,
  ) async {
    try {
      final docRef = _productsCollection.doc(productId);
      final productDoc = await docRef
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 10));
      _ensureOwner(
        productDoc,
        userId,
        unauthorizedMessage: 'No está autorizado para eliminar este producto.',
      );

      if (imageUrl != null && imageUrl.isNotEmpty) {
        await _deleteImageByUrl(imageUrl);
      }

      await docRef.delete().timeout(const Duration(seconds: 12));
    } catch (e, st) {
      _logger.severe('Error eliminando producto', e, st);
      rethrow;
    }
  }

  Stream<List<ProductModel>> _queryProducts({
    required Query<Map<String, dynamic>> query,
  }) {
    return query.snapshots().map(
      (snapshot) => _toSortedProducts(snapshot.docs),
    );
  }

  Query<Map<String, dynamic>> _approvedProductsQuery() {
    return _productsCollection
        .where('status', isEqualTo: ProductStatus.available.name)
        .where(
          'validationStatus',
          isEqualTo: NutritionValidationStatus.approved.value,
        );
  }

  bool _isAllCategory(String category) {
    return category.isEmpty || category.toLowerCase() == 'todas';
  }

  List<ProductModel> _toSortedProducts(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final products = docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();
    products.sort(_sortByCreatedAtDesc);
    return products;
  }

  List<String> _extractCategories(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final categories = docs
        .map((doc) => doc.data()['category']?.toString())
        .where((category) => category != null && category.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    categories.sort();
    return ['Todas', ...categories];
  }

  void _ensureOwner(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String userId, {
    required String unauthorizedMessage,
  }) {
    if (!doc.exists || doc.data()?['userId'] != userId) {
      throw Exception(unauthorizedMessage);
    }
  }

  Future<String> _uploadProductImage(File file, String userId) async {
    final ref = _storage.ref().child(
      'products/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final uploadFile = await _optimizedProductImage(file);

    try {
      final snapshot = await ref
          .putFile(uploadFile, SettableMetadata(contentType: 'image/jpeg'))
          .timeout(const Duration(seconds: 20));
      return snapshot.ref.getDownloadURL().timeout(const Duration(seconds: 10));
    } finally {
      if (uploadFile.path != file.path && await uploadFile.exists()) {
        await uploadFile.delete();
      }
    }
  }

  Future<File> _optimizedProductImage(File file) async {
    try {
      final originalSize = await file.length();

      if (originalSize <= 700 * 1024) return file;

      final targetPath =
          '${Directory.systemTemp.path}/nutrigo_product_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final compressed = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: 1280,
        minHeight: 1280,
        quality: 78,
        format: CompressFormat.jpeg,
        keepExif: false,
      );

      if (compressed == null) return file;

      final compressedFile = File(compressed.path);
      final compressedSize = await compressedFile.length();

      if (compressedSize >= originalSize) {
        await compressedFile.delete();
        return file;
      }

      _logger.info(
        'Imagen de producto optimizada de $originalSize a $compressedSize bytes.',
      );
      return compressedFile;
    } catch (e, st) {
      _logger.warning('No se pudo optimizar la imagen del producto', e, st);
      return file;
    }
  }

  Future<void> _deleteImageByUrl(String url) async {
    try {
      await _storage
          .refFromURL(url)
          .delete()
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      _logger.warning('No se pudo eliminar la imagen: $url');
    }
  }
}
