import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:emprendedor/features/entrepreneur/controllers/product_controller.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/core/utils/product_category_display.dart';
import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';
import 'package:emprendedor/presentation/entrepreneur/products/widgets/list/product_item_actions.dart';

class ProductListItem extends StatelessWidget {
  final ProductModel product;

  const ProductListItem({super.key, required this.product});

  String get _categoryLabel => ProductCategoryDisplay.label(product.category);

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ProductController>();
    const palette = RoleTheme.entrepreneur;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(19.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.035),
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contenido principal
          Padding(
            padding: EdgeInsets.all(11.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductThumb(imageUrl: product.imageUrl),
                SizedBox(width: 11.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre + precio
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.text,
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          _PricePill(price: product.price),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      // Badges: categoría + disponibilidad
                      Wrap(
                        spacing: 5.w,
                        runSpacing: 5.h,
                        children: [
                          _SmallBadge(
                            icon: Icons.category_rounded,
                            label: _categoryLabel,
                            color: palette.primary,
                          ),
                          _SmallBadge(
                            icon: product.status == ProductStatus.available
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            label: product.status.displayName,
                            color: product.status == ProductStatus.available
                                ? palette.secondary
                                : Colors.grey,
                          ),
                        ],
                      ),
                      // Descripción
                      if (product.description.trim().isNotEmpty) ...[
                        SizedBox(height: 5.h),
                        Text(
                          product.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.mutedText,
                            fontSize: 10.5.sp,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      // Meta: kcal + ingredientes
                      SizedBox(height: 7.h),
                      Row(
                        children: [
                          _MetaPill(
                            icon: Icons.local_fire_department_rounded,
                            label: product.approxCalories == null
                                ? 'Sin kcal'
                                : '${product.approxCalories!.toStringAsFixed(0)} kcal',
                            color: palette.accent,
                          ),
                          SizedBox(width: 6.w),
                          _MetaPill(
                            icon: Icons.list_alt_rounded,
                            label: '${product.ingredients.length} ingredientes',
                            color: palette.secondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Barra de validación integrada
          _ValidationBar(product: product),

          // Acciones
          Padding(
            padding: EdgeInsets.fromLTRB(11.w, 7.h, 11.w, 11.h),
            child: ProductItemActions(product: product, controller: controller),
          ),
        ],
      ),
    );
  }
}

// Thumbnail
class _ProductThumb extends StatelessWidget {
  final String? imageUrl;
  const _ProductThumb({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: SizedBox(
        width: 72.w,
        height: 72.w,
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox(),
                errorWidget: (context, url, error) => _placeholder(palette),
              )
            : _placeholder(palette),
      ),
    );
  }

  Widget _placeholder(RolePalette palette) {
    return Container(
      color: palette.primary.withValues(alpha: 0.075),
      child: Icon(
        Icons.restaurant_rounded,
        size: 28.sp,
        color: RoleTheme.iconColorFor(
          Icons.restaurant_rounded,
          fallback: palette.primary,
        ),
      ),
    );
  }
}

// Price pill
class _PricePill extends StatelessWidget {
  final double price;
  const _PricePill({required this.price});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: palette.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        '\$${price.toStringAsFixed(2)}',
        style: TextStyle(
          color: palette.secondary,
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

// Small badge (categoría / disponibilidad)
class _SmallBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SmallBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(99.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: RoleTheme.iconColorFor(icon, fallback: color),
            size: 11.sp,
          ),
          SizedBox(width: 3.w),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9.8.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// Meta pill (kcal / ingredientes)
class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MetaPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(99.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: RoleTheme.iconColorFor(icon, fallback: color),
            size: 11.sp,
          ),
          SizedBox(width: 3.w),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9.8.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// Barra de validación integrada
class _ValidationBar extends StatelessWidget {
  final ProductModel product;
  const _ValidationBar({required this.product});

  @override
  Widget build(BuildContext context) {
    switch (product.validationStatus) {
      case NutritionValidationStatus.approved:
        return _buildBar(
          icon: Icons.verified_rounded,
          color: Colors.green.shade600,
          bgColor: Colors.green.shade50,
          borderColor: Colors.green.shade200,
          left: _buildApprovedText(),
          right: _buildApprovedDate(),
        );
      case NutritionValidationStatus.pending:
        return _buildBar(
          icon: Icons.hourglass_top_rounded,
          color: RoleTheme.iconWarning,
          bgColor: RoleTheme.iconWarning.withValues(alpha: 0.08),
          borderColor: RoleTheme.iconWarning.withValues(alpha: 0.24),
          left: Text(
            'Pendiente de revisión',
            style: TextStyle(
              color: RoleTheme.iconWarning,
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      case NutritionValidationStatus.rejected:
        final comment = product.validationComment?.trim().isNotEmpty == true
            ? product.validationComment!.trim()
            : 'Requiere correcciones';

        return InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: () => _showRejectionReason(context, comment),
          child: _buildBar(
            icon: Icons.cancel_rounded,
            color: Colors.red.shade600,
            bgColor: Colors.red.shade50,
            borderColor: Colors.red.shade200,
            left: Row(
              children: [
                Expanded(
                  child: Text(
                    comment,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(width: 5.w),
                Icon(
                  Icons.touch_app_rounded,
                  color: Colors.red.shade500,
                  size: 12.sp,
                ),
              ],
            ),
          ),
        );
    }
  }

  void _showRejectionReason(BuildContext context, String comment) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
          ),
          icon: Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Icon(
              Icons.report_problem_rounded,
              color: Colors.red.shade600,
              size: 24.sp,
            ),
          ),
          title: Text(
            'Observación del nutricionista',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: TextStyle(
                  color: RoleTheme.entrepreneur.text,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Text(
                  comment,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12.2.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Corrige el producto y vuelve a enviarlo para validación.',
                style: TextStyle(
                  color: RoleTheme.entrepreneur.mutedText,
                  fontSize: 11.2.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
          actionsPadding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 16.h),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: RoleTheme.entrepreneur.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Entendido'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildApprovedText() {
    final name = product.validatedByNutritionistName?.trim();
    final label = name == null || name.isEmpty
        ? 'Validado por nutricionista'
        : 'Validado por $name';

    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.green.shade700,
        fontSize: 9.6.sp,
        fontWeight: FontWeight.w800,
        height: 1,
      ),
    );
  }

  Widget? _buildApprovedDate() {
    if (product.validatedAt == null) return null;
    final date = DateFormat(
      'dd MMM yyyy',
      'es',
    ).format(product.validatedAt!.toDate());
    return Text(
      date,
      style: TextStyle(
        color: Colors.green.shade600,
        fontSize: 8.6.sp,
        fontWeight: FontWeight.w600,
        height: 1,
      ),
    );
  }

  Widget _buildBar({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required Widget left,
    Widget? right,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 11.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 13.sp),
          SizedBox(width: 6.w),
          Expanded(child: left),
          if (right != null) ...[SizedBox(width: 5.w), right],
        ],
      ),
    );
  }
}
