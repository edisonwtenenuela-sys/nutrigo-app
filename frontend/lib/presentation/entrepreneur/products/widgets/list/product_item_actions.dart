import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';
import 'package:emprendedor/presentation/entrepreneur/products/pages/product_form_page.dart';
import 'package:emprendedor/presentation/entrepreneur/products/widgets/shared/product_featured_switch.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class ProductItemActions extends StatelessWidget {
  const ProductItemActions({
    super.key,
    required this.product,
    required this.controller,
  });

  final ProductModel product;
  final ProductController controller;

  bool get _isApproved =>
      product.validationStatus == NutritionValidationStatus.approved;

  bool get _canToggleTop =>
      _isApproved ||
      product.validatedAt != null ||
      product.validatedByNutritionistId?.trim().isNotEmpty == true ||
      product.validatedByNutritionistName?.trim().isNotEmpty == true;

  bool get _isPending =>
      product.validationStatus == NutritionValidationStatus.pending;

  bool get _isAvailable => product.status == ProductStatus.available;

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Row(
      children: [
        SizedBox(
          width: 72.w,
          child: Row(
            children: [
              ProductFeaturedSwitch(
                enabled: _canToggleTop,
                value: product.isFeatured,
                onChanged: (value) => _toggleFeatured(context, value),
              ),
              SizedBox(width: 3.w),
              Icon(
                Icons.star_rounded,
                color: _canToggleTop
                    ? RoleTheme.iconRating
                    : Colors.grey.shade400,
                size: 11.5.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'TOP',
                maxLines: 1,
                style: TextStyle(
                  color: _canToggleTop ? palette.text : Colors.grey.shade400,
                  fontSize: 9.4.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Botones de acción compactos
        _ActionBtn(
          icon: Icons.edit_rounded,
          color: const Color(0xFF64748B),
          onTap: () => _editProduct(context),
        ),
        SizedBox(width: 7.w),
        _ActionBtn(
          icon: _isAvailable
              ? Icons.visibility_off_rounded
              : Icons.visibility_rounded,
          color: _isApproved ? palette.primary : Colors.grey.shade400,
          onTap: _isApproved ? () => _toggleStatus(context) : null,
        ),
        SizedBox(width: 7.w),
        _ActionBtn(
          icon: Icons.delete_rounded,
          color: _isPending ? Colors.grey.shade400 : const Color(0xFFDC2626),
          onTap: () => _deleteProduct(context),
        ),
      ],
    );
  }

  Future<void> _editProduct(BuildContext context) async {
    if (_isPending) {
      await showAppMessage(
        context,
        role: AppFeedbackRole.entrepreneur,
        type: AppFeedbackType.warning,
        title: 'Producto en revisión',
        message:
            'Este producto está pendiente de validación. Podrás editarlo si el nutricionista solicita correcciones.',
      );
      return;
    }

    if (!context.mounted) return;
    AppNavigator.push(context, ProductFormPage(productToEdit: product));
  }

  Future<void> _toggleFeatured(BuildContext context, bool value) async {
    final result = await ProductItemActionController.toggleFeatured(
      controller: controller,
      product: product,
      value: value,
    );
    if (!context.mounted) return;
    await _showActionResult(context, result);
  }

  Future<void> _toggleStatus(BuildContext context) async {
    final result = await ProductItemActionController.toggleStatus(
      controller: controller,
      product: product,
    );
    if (!context.mounted) return;
    await _showActionResult(context, result);
  }

  Future<void> _deleteProduct(BuildContext context) async {
    if (_isPending) {
      await showAppMessage(
        context,
        role: AppFeedbackRole.entrepreneur,
        type: AppFeedbackType.warning,
        title: 'Producto en revisión',
        message:
            'No puedes eliminarlo mientras está pendiente. Espera a que el nutricionista lo apruebe o rechace.',
      );
      return;
    }

    final confirm = await _confirmDelete(context);
    if (!context.mounted || !confirm) return;
    final result = await ProductItemActionController.deleteProduct(
      controller: controller,
      product: product,
    );
    if (!context.mounted) return;
    await _showActionResult(context, result);
  }

  Future<bool> _confirmDelete(BuildContext context) {
    return showAppConfirm(
      context,
      role: AppFeedbackRole.entrepreneur,
      type: AppFeedbackType.warning,
      title: 'Eliminar producto',
      message: '¿Deseas eliminar "${product.name}"?',
      confirmText: 'Eliminar',
      cancelText: 'Cancelar',
    );
  }

  Future<void> _showActionResult(
    BuildContext context,
    ProductItemActionResult result,
  ) {
    return showAppMessage(
      context,
      role: AppFeedbackRole.entrepreneur,
      type: result.success ? AppFeedbackType.success : AppFeedbackType.error,
      title: result.title,
      message: result.message,
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26.w,
        height: 26.w,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Icon(
          icon,
          size: 13.sp,
          color: onTap == null
              ? Colors.grey.shade400
              : RoleTheme.iconColorFor(icon, fallback: color),
        ),
      ),
    );
  }
}
