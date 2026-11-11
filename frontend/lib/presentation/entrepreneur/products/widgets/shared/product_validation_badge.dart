import 'package:flutter/material.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';

class ProductValidationBadge extends StatelessWidget {
  final ProductModel product;

  const ProductValidationBadge({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    switch (product.validationStatus) {
      case NutritionValidationStatus.pending:
        return const _ValidationBox(
          icon: Icons.pending_rounded,
          title: 'Pendiente de revisión',
          subtitle: 'Esperando validación nutricional',
          color: RoleTheme.iconWarning,
        );

      case NutritionValidationStatus.approved:
        final validatedDate = product.validatedAt != null
            ? DateFormat(
                'dd MMM yyyy',
                'es',
              ).format(product.validatedAt!.toDate())
            : null;

        return _ValidationBox(
          icon: Icons.verified_rounded,
          title: 'Validado por nutricionista',
          subtitle:
              product.validatedByNutritionistName?.trim().isNotEmpty == true
              ? product.validatedByNutritionistName!
              : validatedDate ?? 'revisión nutricional aprobada',
          footer: product.validatedByNutritionistName?.trim().isNotEmpty == true
              ? validatedDate
              : null,
          color: RoleTheme.iconValidation,
        );

      case NutritionValidationStatus.rejected:
        return _ValidationBox(
          icon: Icons.cancel_rounded,
          title: 'Requiere correcciones',
          subtitle: product.validationComment?.trim().isNotEmpty == true
              ? product.validationComment!
              : 'Producto rechazado por validación',
          color: RoleTheme.iconDanger,
        );
    }
  }
}

class _ValidationBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? footer;
  final Color color;

  const _ValidationBox({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(9.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 16.sp),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 11.3.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.82),
                    fontSize: 9.8.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (footer != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    footer!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color.withValues(alpha: 0.72),
                      fontSize: 9.2.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
