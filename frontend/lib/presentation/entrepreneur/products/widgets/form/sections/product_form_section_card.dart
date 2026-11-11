import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/entrepreneur/products/widgets/form/sections/product_form_section_title.dart';

class ProductFormSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const ProductFormSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 15.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductFormSectionTitle(title: title, icon: icon),
          SizedBox(height: 13.h),
          child,
        ],
      ),
    );
  }
}








