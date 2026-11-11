import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class BusinessStatusHeader extends StatelessWidget {
  const BusinessStatusHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.store_mall_directory_rounded,
            color: RoleTheme.iconColorFor(
              Icons.store_mall_directory_rounded,
              fallback: palette.primary,
            ),
            size: 20.sp,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estado del negocio',
                style: TextStyle(
                  color: palette.text,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Resumen de acceso y validación',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.mutedText,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}