import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class CartTotalSummary extends StatelessWidget {
  final double subtotal;
  final double discountAmount;
  final double finalTotal;
  final int? itemCount;
  final String? discountLabel;

  const CartTotalSummary({
    super.key,
    required this.subtotal,
    required this.discountAmount,
    required this.finalTotal,
    this.itemCount,
    this.discountLabel,
  });

  String get _subtotalLabel {
    if (itemCount == null) return 'Subtotal';
    final suffix = itemCount == 1 ? 'producto' : 'productos';
    return 'Subtotal ($itemCount $suffix)';
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final hasDiscount = discountAmount > 0;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: _subtotalLabel,
            value: '\$${subtotal.toStringAsFixed(2)}',
          ),
          if (hasDiscount) ...[
            SizedBox(height: 7.h),
            _SummaryRow(
              label: discountLabel ?? 'Descuento',
              value: '-\$${discountAmount.toStringAsFixed(2)}',
              valueColor: RoleTheme.iconPromotion,
            ),
          ],
          Divider(height: 18.h, color: palette.primary.withValues(alpha: 0.12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  color: palette.text,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '\$${finalTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: RoleTheme.iconPayments,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? palette.text,
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}








