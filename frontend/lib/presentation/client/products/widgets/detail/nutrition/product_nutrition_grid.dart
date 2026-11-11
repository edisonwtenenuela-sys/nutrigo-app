import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class ProductNutritionFact {
  final String label;
  final String value;
  final IconData icon;

  const ProductNutritionFact({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class ProductNutritionGrid extends StatelessWidget {
  final List<ProductNutritionFact> facts;

  const ProductNutritionGrid({super.key, required this.facts});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - 8.w) / 2;

        return Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: facts.map((fact) {
            return SizedBox(
              width: tileWidth,
              child: _NutritionTile(fact: fact, palette: palette),
            );
          }).toList(),
        );
      },
    );
  }
}

class _NutritionTile extends StatelessWidget {
  final ProductNutritionFact fact;
  final RolePalette palette;

  const _NutritionTile({required this.fact, required this.palette});

  Color get _tint {
    final label = fact.label.toLowerCase();

    if (label.startsWith('prote')) {
      return RoleTheme.iconValidation;
    }

    if (label == 'grasas') {
      return RoleTheme.iconWarning;
    }

    if (label == 'carbohidratos') {
      return RoleTheme.iconHealth;
    }

    return RoleTheme.iconInfo;
  }

  @override
  Widget build(BuildContext context) {
    final tint = _tint;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(color: tint.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Icon(fact.icon, color: tint, size: 13.sp),
          ),
          SizedBox(width: 7.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fact.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 8.8.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  fact.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 11.2.sp,
                    fontWeight: FontWeight.w900,
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
