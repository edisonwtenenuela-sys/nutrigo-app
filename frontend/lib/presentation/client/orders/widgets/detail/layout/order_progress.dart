import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';

class OrderProgress extends StatelessWidget {
  final OrderStatus status;

  const OrderProgress({super.key, required this.status});

  static const labels = ['Pedido', 'Preparando', 'En camino', 'Entregado'];

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

  Color get _activeColor {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        return RoleTheme.iconWarning;
      case OrderStatus.shipped:
        return RoleTheme.iconInfo;
      case OrderStatus.delivered:
        return RoleTheme.iconValidation;
      case OrderStatus.cancelled:
        return RoleTheme.iconDanger;
    }
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final activeColor = _activeColor;
    final inactiveColor = RoleTheme.brandBorder.withValues(alpha: 0.80);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: RoleTheme.brandBorder.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final segmentStart = constraints.maxWidth / (labels.length * 2);
              final lineWidth = constraints.maxWidth - (segmentStart * 2);
              final activeWidth =
                  lineWidth * (currentStep / (labels.length - 1));

              return SizedBox(
                height: 22.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: segmentStart,
                      right: segmentStart,
                      top: 9.5.w,
                      child: Container(
                        height: 2.2.h,
                        decoration: BoxDecoration(
                          color: inactiveColor,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                    ),
                    Positioned(
                      left: segmentStart,
                      top: 9.5.w,
                      child: Container(
                        width: activeWidth,
                        height: 2.2.h,
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(labels.length, (stepIndex) {
                        final isCompleted = stepIndex <= currentStep;
                        final isCurrent = stepIndex == currentStep;

                        return Expanded(
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: isCurrent ? 19.w : 17.w,
                              height: isCurrent ? 19.w : 17.w,
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? activeColor
                                    : palette.surface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isCompleted
                                      ? activeColor
                                      : inactiveColor,
                                  width: isCurrent ? 1.7.w : 1.4.w,
                                ),
                                boxShadow: isCurrent
                                    ? [
                                  BoxShadow(
                                    color: activeColor.withValues(
                                      alpha: 0.20,
                                    ),
                                    blurRadius: 6.r,
                                    offset: Offset(0, 2.h),
                                  ),
                                ]
                                    : null,
                              ),
                              child: isCompleted
                                  ? Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 10.5.sp,
                              )
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
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
                  style: TextStyle(
                    color: isActive ? palette.text : palette.mutedText,
                    fontSize: 8.1.sp,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}