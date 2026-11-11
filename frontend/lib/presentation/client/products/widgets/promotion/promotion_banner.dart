import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class PromotionBanner extends StatelessWidget {
  final String discountLabel;
  final String? couponCode;

  const PromotionBanner({
    super.key,
    required this.discountLabel,
    this.couponCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: RoleTheme.iconPromotion.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: RoleTheme.iconPromotion.withValues(alpha: 0.11),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_offer_rounded,
            color: RoleTheme.iconColorFor(
              Icons.local_offer_rounded,
              fallback: RoleTheme.iconPromotion,
            ),
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              couponCode == null || couponCode!.trim().isEmpty
                  ? 'Promoción activa: $discountLabel'
                  : '$discountLabel con cupón $couponCode',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: RoleTheme.iconPromotion,
                fontSize: 11.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
