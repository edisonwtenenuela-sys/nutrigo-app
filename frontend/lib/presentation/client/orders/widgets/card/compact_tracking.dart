import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';

class CompactTracking extends StatelessWidget {
  final OrderStatus status;
  final String message;

  const CompactTracking({
    super.key,
    required this.status,
    required this.message,
  });

  static const labels = [
    'Pedido recibido',
    'Preparando',
    'En camino',
    'Entregado',
  ];

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

  Color get _statusColor {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        return RoleTheme.iconWarning;
      case OrderStatus.shipped:
        return RoleTheme.iconValidation;
      case OrderStatus.delivered:
        return RoleTheme.iconInfo;
      case OrderStatus.cancelled:
        return RoleTheme.iconDanger;
    }
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final activeColor = _statusColor;
    final inactiveColor = RoleTheme.brandBorder.withValues(alpha: 0.80);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stepWidth = constraints.maxWidth / labels.length;
          final lineInset = stepWidth / 2;
          final activeWidth = labels.length == 1
              ? 0.0
              : (constraints.maxWidth - stepWidth) *
              (currentStep / (labels.length - 1));

          return Column(
            children: [
              SizedBox(
                height: 18.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: lineInset,
                      right: lineInset,
                      top: 8.w,
                      child: Container(
                        height: 2.h,
                        decoration: BoxDecoration(
                          color: inactiveColor,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                    ),
                    Positioned(
                      left: lineInset,
                      top: 8.w,
                      child: Container(
                        width: activeWidth,
                        height: 2.h,
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                    ),
                    Row(
                      children: labels.asMap().entries.map((entry) {
                        final stepIndex = entry.key;
                        final isActive = stepIndex <= currentStep;

                        return Expanded(
                          child: Center(
                            child: Container(
                              width: 17.w,
                              height: 17.w,
                              decoration: BoxDecoration(
                                color: isActive ? activeColor : palette.surface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isActive ? activeColor : inactiveColor,
                                  width: 1.5.w,
                                ),
                              ),
                              child: isActive
                                  ? Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 10.sp,
                              )
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: labels.asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  final isActive = index <= currentStep;

                  return Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isActive ? palette.text : palette.mutedText,
                        fontSize: 7.2.sp,
                        fontWeight:
                        isActive ? FontWeight.w900 : FontWeight.w700,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}