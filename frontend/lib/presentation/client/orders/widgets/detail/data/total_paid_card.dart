import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class TotalPaidCard extends StatelessWidget {
  final double total;
  final double? subtotal;
  final double? discountAmount;
  final String? couponCode;

  const TotalPaidCard({
    super.key,
    required this.total,
    this.subtotal,
    this.discountAmount,
    this.couponCode,
  });

  bool get hasDiscount {
    return discountAmount != null && discountAmount! > 0;
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final effectiveSubtotal = subtotal ?? total;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: RoleTheme.brandBorder.withValues(alpha: 0.55),
            ),
            boxShadow: [
              BoxShadow(
                color: RoleTheme.iconPayments.withValues(alpha: 0.035),
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumen del pago',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12.6.sp,
                  color: palette.text,
                ),
              ),
              SizedBox(height: 7.h),
              _PriceRow(label: 'Subtotal', value: effectiveSubtotal),
              _PriceRow(label: 'Tarifa de servicio', value: 0),
              if (hasDiscount)
                _PriceRow(
                  label: 'Descuento',
                  value: -discountAmount!,
                  valueColor: RoleTheme.iconValidation,
                ),
              if (couponCode != null && couponCode!.trim().isNotEmpty) ...[
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Icon(
                      Icons.local_offer_rounded,
                      color: RoleTheme.iconColorFor(
                        Icons.local_offer_rounded,
                        fallback: RoleTheme.iconWarning,
                      ),
                      size: 14.sp,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'Cupón usado: ',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w700,
                        color: palette.mutedText,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        couponCode!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: RoleTheme.iconWarning,
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              Divider(
                height: 14.h,
                color: RoleTheme.brandBorder.withValues(alpha: 0.55),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total pagado',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.2.sp,
                        color: palette.text,
                      ),
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: RoleTheme.iconPayments,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              if (hasDiscount) ...[
                SizedBox(height: 7.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: RoleTheme.iconValidation.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    'Ahorraste \$${discountAmount!.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: RoleTheme.iconValidation,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 7.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user_outlined,
              color: RoleTheme.iconColorFor(
                Icons.verified_user_outlined,
                fallback: RoleTheme.iconSecurity,
              ),
              size: 13.sp,
            ),
            SizedBox(width: 4.w),
            Text(
              'Pago 100% seguro',
              style: TextStyle(
                color: palette.mutedText,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final Color? valueColor;

  const _PriceRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.8.sp,
                fontWeight: FontWeight.w700,
                color: palette.mutedText,
              ),
            ),
          ),
          Text(
            value < 0
                ? '-\$${value.abs().toStringAsFixed(2)}'
                : '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: valueColor ?? palette.text,
              fontSize: 10.9.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}