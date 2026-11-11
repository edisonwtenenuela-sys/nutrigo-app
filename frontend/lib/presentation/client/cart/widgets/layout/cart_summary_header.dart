import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class CartSummaryHeader extends StatelessWidget {
  final int itemCount;
  final double subtotal;
  final double finalTotal;

  const CartSummaryHeader({
    super.key,
    required this.itemCount,
    required this.subtotal,
    required this.finalTotal,
  });

  String _formatMoney(double value) => '\$${value.toStringAsFixed(2)}';

  Widget _buildIcon(RolePalette palette) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Icon(
        Icons.shopping_bag_rounded,
        color: RoleTheme.iconColorFor(
          Icons.shopping_bag_rounded,
          fallback: palette.primary,
        ),
        size: 23.sp,
      ),
    );
  }

  Widget _buildSummaryText(RolePalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$itemCount productos en tu pedido',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.text,
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          'Subtotal: ${_formatMoney(subtotal)}',
          style: TextStyle(
            color: palette.mutedText,
            fontSize: 11.2.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildFinalTotal(RolePalette palette) {
    return Text(
      _formatMoney(finalTotal),
      style: TextStyle(
        color: palette.primary,
        fontSize: 17.sp,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          _buildIcon(palette),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildSummaryText(palette),
          ),
          _buildFinalTotal(palette),
        ],
      ),
    );
  }
}