import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';

class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusChip({
    super.key,
    required this.status,
  });

  String get _label {
    switch (status) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.preparing:
        return 'Preparando';
      case OrderStatus.shipped:
        return 'En camino';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  Color get _color {
    switch (status) {
      case OrderStatus.pending:
        return RoleTheme.iconWarning;
      case OrderStatus.confirmed:
        return RoleTheme.iconValidation;
      case OrderStatus.preparing:
        return RoleTheme.iconInfo;
      case OrderStatus.shipped:
        return RoleTheme.entrepreneur.secondary;
      case OrderStatus.delivered:
        return RoleTheme.iconValidation;
      case OrderStatus.cancelled:
        return RoleTheme.iconDanger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: _color.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        _label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: _color,
          fontSize: 10.3.sp,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}