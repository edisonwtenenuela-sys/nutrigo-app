import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/entrepreneur/controllers/product_controller.dart';

class ProductListSummary extends StatelessWidget {
  const ProductListSummary({
    super.key,
    required this.count,
    required this.category,
    required this.onAddProduct,
    required this.sortOption,
    required this.onSortOptionChanged,
    this.selectedFilter,
  });

  final int count;
  final String category;
  final VoidCallback onAddProduct;
  final ProductSortOption sortOption;
  final ValueChanged<ProductSortOption> onSortOptionChanged;
  final ProductValidationFilter? selectedFilter;

  String get _title {
    return switch (selectedFilter) {
      ProductValidationFilter.approved => 'Productos validados',
      ProductValidationFilter.pending => 'Productos pendientes',
      ProductValidationFilter.rejected => 'Productos en corrección',
      null => 'Productos visibles',
    };
  }

  IconData get _icon {
    return switch (selectedFilter) {
      ProductValidationFilter.approved => Icons.verified_rounded,
      ProductValidationFilter.pending => Icons.hourglass_top_rounded,
      ProductValidationFilter.rejected => Icons.report_rounded,
      null => Icons.visibility_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Icon(
            _icon,
            color: RoleTheme.iconColorFor(_icon, fallback: palette.secondary),
            size: 17.sp,
          ),
          SizedBox(width: 7.w),
          Expanded(
            child: Text(
              _title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.text,
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: palette.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(99.r),
              border: Border.all(
                color: palette.secondary.withValues(alpha: 0.22),
              ),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: palette.secondary,
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            constraints: BoxConstraints(maxWidth: 122.w),
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: palette.primary.withValues(alpha: 0.16),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ProductSortOption>(
                value: sortOption,
                isDense: true,
                isExpanded: true,
                borderRadius: BorderRadius.circular(14.r),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: palette.primary,
                  size: 17.sp,
                ),
                style: TextStyle(
                  color: palette.text,
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w800,
                ),
                items: ProductSortOption.values
                    .map(
                      (option) => DropdownMenuItem(
                        value: option,
                        child: Text(
                          option.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (option) {
                  if (option == null) return;
                  onSortOptionChanged(option);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}








