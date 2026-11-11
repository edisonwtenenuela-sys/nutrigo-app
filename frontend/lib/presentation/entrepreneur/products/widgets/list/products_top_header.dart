import 'package:emprendedor/features/entrepreneur/controllers/product_controller.dart';
import 'package:emprendedor/presentation/entrepreneur/products/widgets/list/product_inventory_header.dart';
import 'package:emprendedor/presentation/shared/widgets/category_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductsTopHeader extends StatelessWidget {
  final ProductController controller;

  const ProductsTopHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 0),
          child: ProductInventoryHeader(
            products: controller.allProducts,
            selectedFilter: controller.selectedValidationFilter,
            onFilterSelected: controller.toggleValidationFilter,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 6.h),
          child: const CategoryFilterWidget(),
        ),
      ],
    );
  }
}








