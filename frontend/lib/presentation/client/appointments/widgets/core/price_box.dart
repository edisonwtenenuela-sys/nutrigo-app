import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class PriceBox extends StatelessWidget {
  final double price;

  const PriceBox({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.payments_rounded,
              color: RoleTheme.iconColorFor(
                Icons.payments_rounded,
                fallback: palette.primary,
              ),
              size: 18.sp,
            ),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Valor de consulta',
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 15.sp,
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








