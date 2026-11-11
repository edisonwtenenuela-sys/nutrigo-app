import 'package:flutter/material.dart';

import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:emprendedor/data/models/entrepreneur/index.dart';
import 'package:emprendedor/features/entrepreneur/controllers/promotion_controller.dart';

class CouponFormSubmitResult {
  const CouponFormSubmitResult({
    required this.success,
    required this.title,
    required this.message,
  });

  final bool success;
  final String title;
  final String message;
}

class CouponFormController extends ChangeNotifier {
  CouponFormController({required this.promotion})
    : validityDate = _normalizedToday().add(const Duration(days: 30));

  final PromotionModel promotion;
  final formKey = GlobalKey<FormState>();
  final couponCodeController = TextEditingController();
  final minPurchaseController = TextEditingController(text: '0');

  DateTime? validityDate;
  bool isSubmitting = false;

  DateTime get today => _normalizedToday();

  String get formattedDate => formatDate(validityDate);

  String get discountText {
    if (promotion.discountType == DiscountType.percentage) {
      return '${promotion.discountValue.toStringAsFixed(0)}% OFF';
    }

    return '\$${promotion.discountValue.toStringAsFixed(2)} OFF';
  }

  static DateTime _normalizedToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void applyPickedDate(DateTime picked) {
    validityDate = picked;
    notifyListeners();
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Seleccionar fecha';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String? couponCodeValidator(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Ingresa un código';
    }

    if (text.length < 4) {
      return 'Mínimo 4 caracteres';
    }

    final regex = RegExp(r'^[A-Z0-9]+$');

    if (!regex.hasMatch(text.toUpperCase())) {
      return 'Solo letras y números';
    }

    return null;
  }

  String? minPurchaseValidator(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');

    if (parsed == null) {
      return 'Ingresa un valor válido';
    }

    if (parsed < 0) {
      return 'No puede ser negativo';
    }

    return null;
  }

  CouponFormSubmitResult? validateForSubmit(
    PromotionController promotionController,
  ) {
    if (!promotionController.hasUserId) {
      return const CouponFormSubmitResult(
        success: false,
        title: 'Sesión requerida',
        message: 'Usuario no autenticado.',
      );
    }

    if (!(formKey.currentState?.validate() ?? false) || validityDate == null) {
      return const CouponFormSubmitResult(
        success: false,
        title: 'Formulario incompleto',
        message: 'Completa todos los campos requeridos.',
      );
    }

    if (promotion.id == null || promotion.id!.trim().isEmpty) {
      return const CouponFormSubmitResult(
        success: false,
        title: 'Promoción inválida',
        message: 'Error: promoción inválida.',
      );
    }

    return null;
  }

  Future<CouponFormSubmitResult> submit(
    PromotionController promotionController,
  ) async {
    final validation = validateForSubmit(promotionController);
    if (validation != null) return validation;

    _setSubmitting(true);

    try {
      final couponCode = couponCodeController.text
          .trim()
          .replaceAll(' ', '')
          .toUpperCase();

      final success = await promotionController.createCouponFromPromotion(
        promotion: promotion,
        code: couponCode,
        validityDate: validityDate!,
        minimumPurchase:
            double.tryParse(minPurchaseController.text.trim()) ?? 0,
      );

      return CouponFormSubmitResult(
        success: success,
        title: success ? 'Cupón creado' : 'No se pudo crear',
        message: success
            ? 'Cupón creado exitosamente.'
            : promotionController.errorMessage ?? 'Error al crear cupón.',
      );
    } catch (error) {
      return CouponFormSubmitResult(
        success: false,
        title: 'Error inesperado',
        message: 'No se pudo crear el cupón. ${friendlyErrorMessage(error)}',
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

  @override
  void dispose() {
    couponCodeController.dispose();
    minPurchaseController.dispose();
    super.dispose();
  }
}
