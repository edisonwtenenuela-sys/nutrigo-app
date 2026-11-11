import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';

class ProductStatusDropdown extends StatelessWidget {
  final ProductStatus selectedStatus;
  final ValueChanged<ProductStatus?> onChanged;

  const ProductStatusDropdown({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });

  String _statusLabel(ProductStatus status) {
    switch (status) {
      case ProductStatus.available:
        return 'Disponible';
      case ProductStatus.unavailable:
        return 'No disponible';
    }
  }

  IconData _statusIcon(ProductStatus status) {
    switch (status) {
      case ProductStatus.available:
        return Icons.visibility_rounded;
      case ProductStatus.unavailable:
        return Icons.visibility_off_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return DropdownButtonFormField<ProductStatus>(
      initialValue: selectedStatus,
      isExpanded: true,
      items: ProductStatus.values.map((status) {
        return DropdownMenuItem<ProductStatus>(
          value: status,
          child: Row(
            children: [
              Icon(_statusIcon(status), size: 17.sp, color: palette.primary),
              SizedBox(width: 8.w),
              Text(
                _statusLabel(status),
                style: TextStyle(
                  color: palette.text,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Estado del producto',
        labelStyle: TextStyle(
          color: palette.mutedText,
          fontSize: 11.4.sp,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          Icons.toggle_on_rounded,
          size: 18.sp,
          color: palette.primary,
        ),
        filled: true,
        fillColor: palette.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
      ),
      borderRadius: BorderRadius.circular(16.r),
      dropdownColor: palette.surface,
    );
  }
}








