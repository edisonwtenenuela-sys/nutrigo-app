import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistProductReviewNote extends StatelessWidget {
  const NutritionistProductReviewNote({super.key});

  static const _noteText =
      'Revisa los ingredientes, la información nutricional y la descripción antes de aprobar el producto.';

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Icon(
              Icons.info_outline_rounded,
              size: 16.sp,
              color: RoleTheme.iconColorFor(
                Icons.info_outline_rounded,
                fallback: palette.primary,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              _noteText,
              style: TextStyle(
                fontSize: 10.6.sp,
                fontWeight: FontWeight.w700,
                height: 1.35,
                color: palette.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}