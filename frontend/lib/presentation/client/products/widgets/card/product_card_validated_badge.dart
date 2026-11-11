import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductCardValidatedBadge extends StatelessWidget {
  const ProductCardValidatedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: RoleTheme.iconValidation.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            size: 11.sp,
            color: RoleTheme.iconValidation,
          ),
          SizedBox(width: 4.w),
          Text(
            'Producto validado',
            style: TextStyle(
              fontSize: 8.5.sp,
              fontWeight: FontWeight.w800,
              color: RoleTheme.iconValidation,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
