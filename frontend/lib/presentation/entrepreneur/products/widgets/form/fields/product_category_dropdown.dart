import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/core/utils/product_category_display.dart';

class ProductCategoryDropdown extends StatelessWidget {
  final String? selectedCategory;
  final List<String> categories;
  final ValueChanged<String?> onChanged;
  final bool compact;

  const ProductCategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;
    final availableCategories = categories
        .where((category) => category != 'Todas')
        .toList();

    return DropdownButtonFormField<String>(
      initialValue: availableCategories.contains(selectedCategory)
          ? selectedCategory
          : null,
      isExpanded: true,
      items: availableCategories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(
            ProductCategoryDisplay.label(category),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.text,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 12.4.sp : 13.sp,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'categoría saludable',
        labelStyle: TextStyle(
          color: palette.mutedText,
          fontSize: 11.4.sp,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          Icons.restaurant_menu_rounded,
          size: compact ? 16.sp : 18.sp,
          color: RoleTheme.iconColorFor(
            Icons.restaurant_menu_rounded,
            fallback: palette.primary,
          ),
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: compact ? 38.w : 44.w,
          minHeight: compact ? 38.h : 44.h,
        ),
        filled: true,
        fillColor: palette.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: compact ? 8.h : 12.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: palette.primary.withValues(alpha: 0.12),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: palette.primary.withValues(alpha: 0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(color: palette.primary, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
      ),
      borderRadius: BorderRadius.circular(16.r),
      dropdownColor: palette.surface,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Selecciona una categoría';
        }
        return null;
      },
    );
  }
}








