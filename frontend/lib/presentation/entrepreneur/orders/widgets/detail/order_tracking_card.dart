import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';

class OrderTrackingCard extends StatelessWidget {
  final OrderStatus status;

  const OrderTrackingCard({
    super.key,
    required this.status,
  });

  int get currentStep {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        return 0;
      case OrderStatus.preparing:
        return 1;
      case OrderStatus.shipped:
        return 2;
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.cancelled:
        return 0;
    }
  }

  String get description {
    switch (status) {
      case OrderStatus.pending:
        return 'Esperando confirmación del negocio.';
      case OrderStatus.confirmed:
        return 'Pedido confirmado correctamente.';
      case OrderStatus.preparing:
        return 'Preparando pedido en NutriGo.';
      case OrderStatus.shipped:
        return 'Pedido en camino al cliente.';
      case OrderStatus.delivered:
        return 'Pedido entregado exitosamente.';
      case OrderStatus.cancelled:
        return 'Pedido cancelado.';
    }
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final activeColor = status == OrderStatus.cancelled
        ? RoleTheme.iconDanger
        : palette.primary;

    final inactiveColor = palette.primary.withValues(alpha: 0.14);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: [
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            children: List.generate(7, (index) {
              if (index.isOdd) {
                final lineIndex = index ~/ 2;

                return Expanded(
                  child: Container(
                    height: 2.h,
                    decoration: BoxDecoration(
                      color: lineIndex < currentStep
                          ? activeColor
                          : inactiveColor,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                );
              }

              final step = index ~/ 2;
              final completed = step <= currentStep;

              return Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed ? activeColor : palette.surface,
                  border: Border.all(
                    color: completed ? activeColor : inactiveColor,
                    width: 1.6.w,
                  ),
                ),
                child: completed
                    ? Icon(
                  Icons.check,
                  size: 11.sp,
                  color: palette.surface,
                )
                    : null,
              );
            }),
          ),
          SizedBox(height: 8.h),
          Row(
            children: const [
              _TrackingLabel('Recibido'),
              _TrackingLabel('Preparando'),
              _TrackingLabel('En camino'),
              _TrackingLabel('Entregado'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrackingLabel extends StatelessWidget {
  final String text;

  const _TrackingLabel(this.text);

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: palette.mutedText,
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}