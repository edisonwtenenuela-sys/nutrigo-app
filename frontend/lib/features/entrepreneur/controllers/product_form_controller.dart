import 'package:flutter/material.dart';

import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/product_controller.dart';

class ProductFormSubmitResult {
  const ProductFormSubmitResult({required this.success, required this.message});

  final bool success;
  final String message;
}

class ProductFormController extends ChangeNotifier {
  ProductFormController({ProductModel? product})
    : productToEdit = product,
      nameController = TextEditingController(text: product?.name ?? ''),
      priceController = TextEditingController(
        text: product != null ? product.price.toStringAsFixed(2) : '',
      ),
      descriptionController = TextEditingController(
        text: product?.description ?? '',
      ),
      ingredientsController = TextEditingController(
        text: product?.ingredients.join(', ') ?? '',
      ),
      servingSizeController = TextEditingController(
        text: product?.servingSize ?? '',
      ),
      caloriesController = TextEditingController(
        text: product?.approxCalories?.toStringAsFixed(0) ?? '',
      ),
      proteinController = TextEditingController(
        text: product?.protein?.toStringAsFixed(0) ?? '',
      ),
      carbohydratesController = TextEditingController(
        text: product?.carbohydrates?.toStringAsFixed(0) ?? '',
      ),
      fatsController = TextEditingController(
        text: product?.fats?.toStringAsFixed(0) ?? '',
      ),
      allergensController = TextEditingController(
        text: product?.allergens.join(', ') ?? '',
      ),
      dietaryTagsController = TextEditingController(
        text: product?.dietaryTags.join(', ') ?? '',
      ),
      selectedCategory = product?.category,
      selectedStatus = product?.status ?? ProductStatus.available;

  final ProductModel? productToEdit;
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController descriptionController;
  final TextEditingController ingredientsController;
  final TextEditingController servingSizeController;
  final TextEditingController caloriesController;
  final TextEditingController proteinController;
  final TextEditingController carbohydratesController;
  final TextEditingController fatsController;
  final TextEditingController allergensController;
  final TextEditingController dietaryTagsController;

  String? selectedCategory;
  ProductStatus selectedStatus;
  int _currentStep = 0;

  bool get isEditing => productToEdit != null;
  bool get isBasicStep => _currentStep == 0;
  bool get isNutritionStep => _currentStep == 1;
  bool get isReviewStep => _currentStep == 2;
  int get currentStep => _currentStep;
  bool get isBeverageCategory =>
      selectedCategory?.trim().toLowerCase() == 'bebidas saludables';
  String get servingSizeUnit => isBeverageCategory ? 'ml' : 'g';
  String get servingSizeLabel =>
      'Tamaño de porción, ej. ${isBeverageCategory ? '350 ml' : '350 g'}';

  void goToBasicStep() {
    if (_currentStep == 0) return;
    _currentStep = 0;
    notifyListeners();
  }

  void goToNutritionStep() {
    if (_currentStep == 1) return;
    _currentStep = 1;
    notifyListeners();
  }

  void goToReviewStep() {
    if (_currentStep == 2) return;
    _currentStep = 2;
    notifyListeners();
  }

  void setCategory(String? value) {
    if (selectedCategory == value) return;
    selectedCategory = value;
    notifyListeners();
  }

  void setStatus(ProductStatus? value) {
    if (value == null || selectedStatus == value) return;
    selectedStatus = value;
    notifyListeners();
  }

  String fallbackCategory(ProductController controller) {
    return controller.categories.firstWhere(
      (category) => category != 'Todas',
      orElse: () => 'Sin categoría',
    );
  }

  String? requiredValidator(String? value) {
    return (value == null || value.trim().isEmpty) ? 'Obligatorio' : null;
  }

  String? priceValidator(String? value) {
    final price = double.tryParse(value?.trim() ?? '');
    return (price == null || price < 0) ? 'Inválido' : null;
  }

  String? caloriesValidator(String? value) {
    return optionalNumberValidator(value);
  }

  String? optionalNumberValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final number = double.tryParse(value.trim());
    return (number == null || number < 0) ? 'Inválido' : null;
  }

  double? _optionalDouble(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : double.tryParse(value);
  }

  String _normalizedServingSize() {
    final value = servingSizeController.text.trim();
    if (value.isEmpty) return value;

    final hasUnit = RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚ]').hasMatch(value);
    if (hasUnit) return value;

    return '$value $servingSizeUnit';
  }

  List<String> _commaSeparatedValues(TextEditingController controller) {
    return controller.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  bool _hasProductImage(ProductController controller) {
    final hasSelectedImage = controller.selectedImageFile != null;
    final hasExistingImage = productToEdit?.imageUrl?.trim().isNotEmpty == true;
    return hasSelectedImage || hasExistingImage;
  }

  ProductFormSubmitResult? validateBasicStep(ProductController controller) {
    if (!(formKey.currentState?.validate() ?? false)) {
      return const ProductFormSubmitResult(
        success: false,
        message: 'Completa los datos básicos del producto.',
      );
    }

    if (!_hasProductImage(controller)) {
      return const ProductFormSubmitResult(
        success: false,
        message: 'Agrega una foto clara del producto para la validación.',
      );
    }

    return null;
  }

  ProductFormSubmitResult? validateNutritionStep() {
    if (!(formKey.currentState?.validate() ?? false)) {
      return const ProductFormSubmitResult(
        success: false,
        message: 'Completa la información nutricional del producto.',
      );
    }

    return null;
  }

  Future<ProductFormSubmitResult> submit(ProductController controller) async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return const ProductFormSubmitResult(
        success: false,
        message: 'Completa los campos requeridos.',
      );
    }

    if (!_hasProductImage(controller)) {
      return const ProductFormSubmitResult(
        success: false,
        message: 'Agrega una foto clara del producto para la validación.',
      );
    }

    final product = buildProduct(controller);
    final success = isEditing
        ? await controller.updateProduct(
            product,
            originalValidationStatus: productToEdit?.validationStatus,
          )
        : await controller.addProduct(product);

    return ProductFormSubmitResult(
      success: success,
      message: success
          ? 'Producto guardado correctamente.'
          : controller.errorMessage ?? 'No se pudo guardar el producto.',
    );
  }

  ProductModel buildProduct(ProductController controller) {
    final price = double.tryParse(priceController.text.trim());
    final calories = _optionalDouble(caloriesController);
    final protein = _optionalDouble(proteinController);
    final carbohydrates = _optionalDouble(carbohydratesController);
    final fats = _optionalDouble(fatsController);

    return ProductModel(
      id: productToEdit?.id,
      name: nameController.text.trim(),
      price: price ?? 0,
      imageUrl: productToEdit?.imageUrl,
      status: selectedStatus,
      category: selectedCategory ?? fallbackCategory(controller),
      description: descriptionController.text.trim(),
      ingredients: _commaSeparatedValues(ingredientsController),
      isFeatured: productToEdit?.isFeatured ?? false,
      servingSize: _normalizedServingSize(),
      approxCalories: calories,
      protein: protein,
      carbohydrates: carbohydrates,
      fats: fats,
      allergens: _commaSeparatedValues(allergensController),
      dietaryTags: _commaSeparatedValues(dietaryTagsController),
      userId: controller.userId,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    ingredientsController.dispose();
    servingSizeController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbohydratesController.dispose();
    fatsController.dispose();
    allergensController.dispose();
    dietaryTagsController.dispose();
    super.dispose();
  }
}
