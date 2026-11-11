import 'package:flutter/material.dart';

import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:emprendedor/data/models/entrepreneur/promotions/promotion_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/promotion_controller.dart';

class PromotionFormSubmitResult {
  const PromotionFormSubmitResult({
    required this.success,
    required this.title,
    required this.message,
  });

  final bool success;
  final String title;
  final String message;
}

class PromotionFormController extends ChangeNotifier {
  PromotionFormController({PromotionModel? promotion})
    : promotionToEdit = promotion,
      nameController = TextEditingController(text: promotion?.name ?? ''),
      descriptionController = TextEditingController(
        text: promotion?.description ?? '',
      ),
      discountValueController = TextEditingController(
        text: promotion?.discountValue.toString() ?? '',
      ),
      discountType = promotion?.discountType ?? DiscountType.percentage,
      selectedScope = promotion?.scope ?? PromotionScope.all,
      selectedProductIds = {...(promotion?.productIds ?? [])},
      startDate = promotion?.startDate.toDate() ?? _normalizedToday(),
      endDate =
          promotion?.endDate.toDate() ??
          _normalizedToday().add(const Duration(days: 30));

  final PromotionModel? promotionToEdit;
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController discountValueController;

  DiscountType discountType;
  PromotionScope selectedScope;
  Set<String> selectedProductIds;
  DateTime startDate;
  DateTime endDate;
  bool isSubmitting = false;

  bool get isEditing => promotionToEdit != null;
  DateTime get today => _normalizedToday();

  static DateTime _normalizedToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void setDiscountType(DiscountType value) {
    if (discountType == value) return;
    discountType = value;
    notifyListeners();
  }

  void setScope(PromotionScope value) {
    if (selectedScope == value) return;
    selectedScope = value;
    if (value == PromotionScope.all) {
      selectedProductIds.clear();
    }
    notifyListeners();
  }

  void toggleProduct(String productId) {
    if (selectedProductIds.contains(productId)) {
      selectedProductIds.remove(productId);
    } else {
      selectedProductIds.add(productId);
    }
    notifyListeners();
  }

  void applyPickedDate({required bool isStart, required DateTime picked}) {
    if (isStart) {
      startDate = picked;
      if (endDate.isBefore(startDate)) {
        endDate = startDate.add(const Duration(days: 30));
      }
    } else {
      endDate = picked;
    }
    notifyListeners();
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }
    return null;
  }

  String? discountValidator(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');

    if (parsed == null || parsed < 0) {
      return 'Valor inv\u00e1lido';
    }

    if (discountType == DiscountType.percentage && parsed > 100) {
      return 'M\u00e1ximo 100%';
    }

    return null;
  }

  bool _hasValidBasicFields() {
    return requiredValidator(nameController.text) == null &&
        discountValidator(discountValueController.text) == null;
  }

  PromotionFormSubmitResult? validateForSubmit(
    PromotionController promotionController,
  ) {
    if (!promotionController.hasUserId) {
      return const PromotionFormSubmitResult(
        success: false,
        title: 'Sesi\u00f3n requerida',
        message: 'Usuario no autenticado.',
      );
    }

    if (!_hasValidBasicFields()) {
      return const PromotionFormSubmitResult(
        success: false,
        title: 'Formulario incompleto',
        message: 'Completa todos los campos requeridos.',
      );
    }

    if (selectedScope == PromotionScope.product && selectedProductIds.isEmpty) {
      return const PromotionFormSubmitResult(
        success: false,
        title: 'Selecciona productos',
        message: 'Selecciona al menos un producto para esta promoci\u00f3n.',
      );
    }

    return null;
  }

  Future<PromotionFormSubmitResult> submit(
    PromotionController promotionController,
  ) async {
    final validation = validateForSubmit(promotionController);
    if (validation != null) return validation;

    _setSubmitting(true);

    try {
      final success = await promotionController.createOrUpdatePromotionFromForm(
        id: promotionToEdit?.id,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        discountType: discountType,
        discountValue:
            double.tryParse(discountValueController.text.trim()) ?? 0,
        startDate: startDate,
        endDate: endDate,
        scope: selectedScope,
        productIds: selectedProductIds.toList(),
      );

      return PromotionFormSubmitResult(
        success: success,
        title: success ? 'Promoci\u00f3n guardada' : 'No se pudo guardar',
        message: success
            ? 'Promoci\u00f3n ${isEditing ? "actualizada" : "creada"} con \u00e9xito.'
            : promotionController.errorMessage ??
                  'Error al guardar promoci\u00f3n.',
      );
    } catch (error) {
      return PromotionFormSubmitResult(
        success: false,
        title: 'Error inesperado',
        message:
            'No se pudo guardar la promoción. ${friendlyErrorMessage(error)}',
      );
    } finally {
      _setSubmitting(false);
    }
  }

  void _setSubmitting(bool value) {
    if (isSubmitting == value) return;
    isSubmitting = value;
    notifyListeners();
  }

  void clearSubmittingState() {
    _setSubmitting(false);
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    discountValueController.dispose();
    super.dispose();
  }
}
