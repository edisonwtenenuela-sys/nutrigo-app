import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/index.dart';
import 'package:emprendedor/presentation/entrepreneur/promotions/widgets/index.dart';

class ProductSelectionSection extends StatelessWidget {
  final PromotionScope selectedScope;
  final List<ProductModel> products;
  final Set<String> selectedProductIds;
  final bool isLoading;
  final ValueChanged<PromotionScope> onScopeChanged;
  final ValueChanged<String> onToggleProduct;

  const ProductSelectionSection({
    super.key,
    required this.selectedScope,
    required this.products,
    required this.selectedProductIds,
    required this.isLoading,
    required this.onScopeChanged,
    required this.onToggleProduct,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final availableProducts = products
        .where((product) => product.id?.trim().isNotEmpty ?? false)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aplicar promoción a',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.text,
            fontSize: 11.8.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 9.h),
        Row(
          children: [
            Expanded(
              child: _ScopeChip(
                label: 'Todo el catálogo',
                icon: Icons.storefront_rounded,
                selected: selectedScope == PromotionScope.all,
                onTap: () => onScopeChanged(PromotionScope.all),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _ScopeChip(
                label: 'Productos',
                icon: Icons.checklist_rounded,
                selected: selectedScope == PromotionScope.product,
                onTap: () => onScopeChanged(PromotionScope.product),
              ),
            ),
          ],
        ),
        if (selectedScope == PromotionScope.product) ...[
          SizedBox(height: 11.h),
          if (isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Center(
                child: SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: CircularProgressIndicator(
                    color: palette.primary,
                    strokeWidth: 2.2,
                  ),
                ),
              ),
            )
          else if (availableProducts.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(11.w),
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: 0.045),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: palette.primary.withValues(alpha: 0.11),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: RoleTheme.iconColorFor(
                      Icons.inventory_2_outlined,
                      fallback: palette.primary,
                    ),
                    size: 18.sp,
                  ),
                  SizedBox(width: 9.w),
                  Expanded(
                    child: Text(
                      'No tienes productos disponibles para seleccionar.',
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: availableProducts.map((product) {
                final productId = product.id!.trim();

                return Padding(
                  padding: EdgeInsets.only(bottom: 7.h),
                  child: ProductSelectionTile(
                    product: product,
                    isSelected: selectedProductIds.contains(productId),
                    onTap: () => onToggleProduct(productId),
                  ),
                );
              }).toList(),
            ),
        ],
      ],
    );
  }
}

class _ScopeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ScopeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final iconColor = selected
        ? RoleTheme.iconColorFor(icon, fallback: palette.primary)
        : palette.mutedText;

    final text = label.trim().isNotEmpty ? label.trim() : 'Opción';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: 9.w,
          vertical: 9.h,
        ),
        decoration: BoxDecoration(
          color: selected
              ? palette.primary.withValues(alpha: 0.10)
              : palette.primary.withValues(alpha: 0.028),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected
                ? palette.primary.withValues(alpha: 0.34)
                : palette.primary.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? palette.primary : palette.text,
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}