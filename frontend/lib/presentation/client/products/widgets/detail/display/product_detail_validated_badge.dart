import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductDetailValidatedBadge extends StatelessWidget {
  final String? nutritionistName;

  const ProductDetailValidatedBadge({super.key, this.nutritionistName});

  @override
  Widget build(BuildContext context) {
    final cleanName = nutritionistName?.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: RoleTheme.iconValidation.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: RoleTheme.iconValidation.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: RoleTheme.iconValidation.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_rounded,
              color: RoleTheme.iconValidation,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Producto validado',
                  style: TextStyle(
                    color: RoleTheme.iconValidation,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  cleanName != null && cleanName.isNotEmpty
                      ? 'Validado por: $cleanName'
                      : 'Validado por: Nutricionista',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RoleTheme.iconValidation.withValues(alpha: 0.86),
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
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
