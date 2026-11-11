import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class CouponPromotionSummaryCard extends StatelessWidget {
  final String promotionName;
  final String discountText;

  const CouponPromotionSummaryCard({
    super.key,
    required this.promotionName,
    required this.discountText,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final title = promotionName.trim().isNotEmpty
        ? promotionName.trim()
        : 'Promoción';
    final discount = discountText.trim().isNotEmpty
        ? discountText.trim()
        : 'Descuento aplicado';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 10.h,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.035),
            blurRadius: 10.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(
              Icons.discount_rounded,
              color: RoleTheme.iconColorFor(
                Icons.discount_rounded,
                fallback: palette.primary,
              ),
              size: 21.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  discount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.primary,
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