import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/product_controller.dart';

class ProductInventoryHeader extends StatelessWidget {
  const ProductInventoryHeader({
    super.key,
    required this.products,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final List<ProductModel> products;
  final ProductValidationFilter? selectedFilter;
  final ValueChanged<ProductValidationFilter> onFilterSelected;

  int get approvedCount => products
      .where((p) => p.validationStatus == NutritionValidationStatus.approved)
      .length;

  int get pendingCount => products
      .where((p) => p.validationStatus == NutritionValidationStatus.pending)
      .length;

  int get rejectedCount => products
      .where((p) => p.validationStatus == NutritionValidationStatus.rejected)
      .length;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: RoleTheme.brandBadgeBackground,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: RoleTheme.brandSoft.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: RoleTheme.brandPrimary.withValues(alpha: 0.08),
            blurRadius: 16.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(
                    color: RoleTheme.brandSoft.withValues(alpha: 0.55),
                  ),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: RoleTheme.iconColorFor(
                    Icons.inventory_2_outlined,
                    fallback: RoleTheme.brandPrimary,
                  ),
                  size: 26.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catálogo del negocio',
                      maxLines: 2,
                      style: TextStyle(
                        color: RoleTheme.brandText,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Envía productos a revisión nutricional',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: RoleTheme.brandMutedText,
                        fontSize: 10.8.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _InventoryMetric(
                    label: 'Validados',
                    value: approvedCount,
                    color: RoleTheme.iconValidation,
                    isSelected:
                        selectedFilter == ProductValidationFilter.approved,
                    onTap: () =>
                        onFilterSelected(ProductValidationFilter.approved),
                  ),
                ),
                _MetricDivider(),
                Expanded(
                  child: _InventoryMetric(
                    label: 'Pendientes',
                    value: pendingCount,
                    color: RoleTheme.iconWarning,
                    isSelected:
                        selectedFilter == ProductValidationFilter.pending,
                    onTap: () =>
                        onFilterSelected(ProductValidationFilter.pending),
                  ),
                ),
                _MetricDivider(),
                Expanded(
                  child: _InventoryMetric(
                    label: 'Corrección',
                    value: rejectedCount,
                    color: RoleTheme.iconDanger,
                    isSelected:
                        selectedFilter == ProductValidationFilter.rejected,
                    onTap: () =>
                        onFilterSelected(ProductValidationFilter.rejected),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryMetric extends StatelessWidget {
  const _InventoryMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int value;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 3.w),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$value',
                style: TextStyle(
                  color: color,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: RoleTheme.brandMutedText,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 34.h, color: RoleTheme.brandBorder);
  }
}
