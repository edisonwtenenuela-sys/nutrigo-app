import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/shared/widgets/buttons/app_action_button.dart';

class CartCouponBox extends StatelessWidget {
  final TextEditingController couponController;
  final bool isProcessingOrder;
  final bool isApplyingCoupon;
  final String? appliedCouponCode;
  final String? couponMessage;
  final String? couponNotice;
  final bool hasDiscount;
  final VoidCallback onApplyCoupon;
  final VoidCallback onRemoveCoupon;

  const CartCouponBox({
    super.key,
    required this.couponController,
    required this.isProcessingOrder,
    required this.isApplyingCoupon,
    required this.appliedCouponCode,
    required this.couponMessage,
    required this.couponNotice,
    required this.hasDiscount,
    required this.onApplyCoupon,
    required this.onRemoveCoupon,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    final hasAppliedCoupon =
        hasDiscount &&
        appliedCouponCode != null &&
        appliedCouponCode!.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: hasDiscount
              ? RoleTheme.iconPromotion.withValues(alpha: 0.24)
              : palette.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.confirmation_number_outlined,
                size: 17.sp,
                color: RoleTheme.iconPromotion,
              ),
              SizedBox(width: 6.w),
              Text(
                'Cupón de descuento',
                style: TextStyle(
                  color: palette.text,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (hasAppliedCoupon)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: RoleTheme.iconPromotion.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Cupón aplicado: $appliedCouponCode',
                      style: TextStyle(
                        color: RoleTheme.iconPromotion,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: isProcessingOrder ? null : onRemoveCoupon,
                    child: Icon(
                      Icons.close_rounded,
                      color: RoleTheme.iconDanger,
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: couponController,
                    enabled: !isProcessingOrder && !isApplyingCoupon,
                    textCapitalization: TextCapitalization.characters,
                    style: TextStyle(
                      color: palette.text,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ej.: SALUD20',
                      hintStyle: TextStyle(
                        color: palette.mutedText,
                        fontSize: 11.5.sp,
                      ),
                      filled: true,
                      fillColor: palette.surface,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                SizedBox(
                  width: 84.w,
                  child: ClientActionButton(
                    label: 'Aplicar',
                    loadingLabel: '...',
                    height: 38.h,
                    fontSize: 11.sp,
                    isLoading: isApplyingCoupon,
                    onPressed: isProcessingOrder ? null : onApplyCoupon,
                  ),
                ),
              ],
            ),
          if (couponMessage != null && couponMessage!.trim().isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              couponMessage!,
              style: TextStyle(
                color: hasDiscount
                    ? RoleTheme.iconPromotion
                    : RoleTheme.iconDanger,
                fontSize: 10.8.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if ((couponMessage == null || couponMessage!.trim().isEmpty) &&
              couponNotice != null &&
              couponNotice!.trim().isNotEmpty) ...[
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: RoleTheme.iconInfo,
                  size: 14.sp,
                ),
                SizedBox(width: 5.w),
                Expanded(
                  child: Text(
                    couponNotice!,
                    style: TextStyle(
                      color: RoleTheme.iconInfo,
                      fontSize: 10.8.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.22,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
