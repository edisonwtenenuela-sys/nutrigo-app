import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistMiniPrice extends StatelessWidget {
  final double price;

  const NutritionistMiniPrice({
    super.key,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: RoleTheme.iconPayments.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: RoleTheme.iconPayments.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.payments_rounded,
            color: RoleTheme.iconColorFor(
              Icons.payments_rounded,
              fallback: RoleTheme.iconPayments,
            ),
            size: 18.sp,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              '\$${price.toStringAsFixed(2)}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: RoleTheme.iconPayments,
                fontSize: 13.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}