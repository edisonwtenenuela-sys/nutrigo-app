import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class CouponAvailableCard extends StatelessWidget {
  final String couponCode;
  final String discountLabel;

  const CouponAvailableCard({
    super.key,
    required this.couponCode,
    required this.discountLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: RoleTheme.iconPromotion.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: RoleTheme.iconPromotion.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: RoleTheme.iconPromotion.withValues(alpha: 0.085),
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(
              Icons.confirmation_number_rounded,
              color: RoleTheme.iconColorFor(
                Icons.confirmation_number_rounded,
                fallback: RoleTheme.iconPromotion,
              ),
              size: 16.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  couponCode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RoleTheme.brandText,
                    fontSize: 13.4.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Promoción disponible',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RoleTheme.brandMutedText,
                    fontSize: 9.8.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: RoleTheme.iconPromotion.withValues(alpha: 0.085),
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Text(
              discountLabel,
              style: TextStyle(
                color: RoleTheme.iconPromotion,
                fontSize: 10.2.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
