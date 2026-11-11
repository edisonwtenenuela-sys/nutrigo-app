import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';

class InfoPanel extends StatelessWidget {
  final OrderModel order;
  final String formattedDate;
  final String paymentMethodText;

  const InfoPanel({
    super.key,
    required this.order,
    required this.formattedDate,
    required this.paymentMethodText,
  });

  List<Widget> _buildRows() {
    return [
      InfoRow(
        icon: Icons.location_on_outlined,
        title: 'Dirección',
        value: order.shippingAddress,
        maxLines: 2,
      ),
      const DividerLine(),
      InfoRow(
        icon: Icons.payment_outlined,
        title: 'Método de pago',
        value: paymentMethodText,
      ),
      const DividerLine(),
      InfoRow(
        icon: Icons.calendar_month_outlined,
        title: 'Fecha',
        value: formattedDate,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: RoleTheme.brandBorder.withValues(alpha: 0.55),
        ),
      ),
      child: Column(children: _buildRows()),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final int maxLines;

  const InfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final semanticIconColor = RoleTheme.iconColorFor(
      icon,
      fallback: palette.primary,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15.r,
            backgroundColor: semanticIconColor.withValues(alpha: 0.10),
            child: Icon(icon, color: semanticIconColor, size: 16.sp),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: palette.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  value,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.mutedText,
                    height: 1.15,
                    fontSize: 10.8.sp,
                    fontWeight: FontWeight.w500,
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

class DividerLine extends StatelessWidget {
  const DividerLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1.h,
      indent: 48.w,
      endIndent: 12.w,
      color: RoleTheme.brandBorder.withValues(alpha: 0.55),
    );
  }
}