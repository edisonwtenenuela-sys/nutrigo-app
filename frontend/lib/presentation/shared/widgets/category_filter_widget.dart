import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/core/utils/product_category_display.dart';
import 'package:emprendedor/features/entrepreneur/controllers/product_controller.dart';

class CategoryFilterWidget extends StatelessWidget {
  const CategoryFilterWidget({super.key});

  IconData _iconFor(String category) {
    final normalized = category.toLowerCase();

    if (category == 'Todas') return Icons.grid_view_rounded;
    if (normalized.contains('ensaladas')) return Icons.eco_rounded;
    if (normalized.contains('sopas')) return Icons.soup_kitchen_rounded;
    if (normalized.contains('bebidas')) return Icons.local_drink_rounded;
    if (normalized.contains('postres')) return Icons.cake_rounded;
    if (normalized.contains('snacks')) return Icons.cookie_rounded;
    if (normalized.contains('fitness')) return Icons.fitness_center_rounded;
    if (normalized.contains('keto')) return Icons.egg_alt_rounded;
    if (normalized.contains('vegano')) return Icons.spa_rounded;

    return Icons.restaurant_menu_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final productController = context.watch<ProductController>();
    const palette = RoleTheme.entrepreneur;

    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: productController.categories.length,
        separatorBuilder: (context, index) => SizedBox(width: 6.w),
        itemBuilder: (context, index) {
          final category = productController.categories[index];
          final isSelected = productController.selectedCategory == category;
          final icon = _iconFor(category);

          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: () => productController.setSelectedCategory(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: category == 'Todas' ? 50.w : 66.w,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? palette.primary
                      : palette.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected
                        ? palette.primary
                        : palette.primary.withValues(alpha: 0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: palette.shadow,
                      blurRadius: 7.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: isSelected
                          ? Colors.white
                          : RoleTheme.iconColorFor(
                        icon,
                        fallback: palette.primary,
                      ),
                      size: 14.sp,
                    ),
                    SizedBox(height: 1.5.h),
                    Text(
                      ProductCategoryDisplay.label(category),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected ? Colors.white : palette.text,
                        fontSize: 8.8.sp,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}