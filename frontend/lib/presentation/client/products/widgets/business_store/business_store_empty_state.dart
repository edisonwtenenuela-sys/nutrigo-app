import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BusinessStoreEmptyState extends StatelessWidget {
  const BusinessStoreEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 34.h),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: RoleTheme.iconHealth.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: RoleTheme.iconColorFor(
              Icons.inventory_2_outlined,
              fallback: RoleTheme.iconHealth,
            ),
            size: 34.sp,
          ),
          SizedBox(height: 10.h),
          Text(
            'Sin productos disponibles',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.text,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'Este negocio todavía no tiene productos validados visibles.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 11.5.sp,
              height: 1.25,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
