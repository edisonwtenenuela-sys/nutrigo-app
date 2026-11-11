import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';

class OrderManagementCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onCancel;
  final VoidCallback onAdvance;
  final VoidCallback onManualUpdate;
  final Color Function(OrderStatus status) getStatusColor;

  const OrderManagementCard({
    super.key,
    required this.order,
    required this.onCancel,
    required this.onAdvance,
    required this.onManualUpdate,
    required this.getStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        alignment: WrapAlignment.center,
        children: [
          if (order.canBeCancelled)
            _ActionButton(
              icon: Icons.cancel_outlined,
              label: 'Cancelar',
              color: RoleTheme.iconDanger,
              outlined: true,
              onTap: onCancel,
            ),
          if (order.nextStatus != null)
            _ActionButton(
              icon: Icons.arrow_forward_rounded,
              label: order.nextStatusText,
              color: palette.primary,
              onTap: onAdvance,
            ),
          if (order.canChangeStatus)
            _ActionButton(
              icon: Icons.edit_note_rounded,
              label: 'Manual',
              color: palette.secondary,
              outlined: true,
              onTap: onManualUpdate,
            ),
          if (!order.canChangeStatus)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                color: getStatusColor(
                  order.status,
                ).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    order.status == OrderStatus.delivered
                        ? Icons.check_circle
                        : Icons.block,
                    size: 16.sp,
                    color: getStatusColor(order.status),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    order.status == OrderStatus.delivered
                        ? 'Pedido finalizado'
                        : 'Pedido cancelado',
                    style: TextStyle(
                      color: getStatusColor(order.status),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool outlined;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16.sp),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(
            color: color.withValues(alpha: 0.30),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 8.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16.sp),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.055),
        foregroundColor: color,
        side: BorderSide(
          color: color.withValues(alpha: 0.22),
        ),
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 9.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
      ),
    );
  }
}