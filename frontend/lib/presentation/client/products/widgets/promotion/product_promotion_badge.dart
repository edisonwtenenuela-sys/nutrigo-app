import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ProductPromotionBadge extends StatelessWidget {
  final String label;
  final bool showOfferIcon;

  const ProductPromotionBadge({
    super.key,
    required this.label,
    this.showOfferIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.5.h),
      decoration: BoxDecoration(
        color: RoleTheme.iconPromotion.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: RoleTheme.iconPromotion.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showOfferIcon) ...[
            Icon(
              Icons.local_offer_rounded,
              color: RoleTheme.iconPromotion,
              size: 13.sp,
            ),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: TextStyle(
              color: RoleTheme.iconPromotion,
              fontSize: 9.8.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
