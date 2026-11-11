import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';

class MiniOrderProgress extends StatelessWidget {
  final OrderStatus status;

  const MiniOrderProgress({super.key, required this.status});

  static const labels = ['Recibido', 'Preparando', 'En camino', 'Entregado'];

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

  Color _activeColor() {
    if (status == OrderStatus.cancelled) return RoleTheme.iconDanger;

    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        return RoleTheme.entrepreneur.primary;
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
    const palette = RoleTheme.entrepreneur;
    final activeColor = _activeColor();

    if (status == OrderStatus.cancelled) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: RoleTheme.iconDanger.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(13.r),
          border: Border.all(
            color: RoleTheme.iconDanger.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cancel_outlined,
              color: RoleTheme.iconDanger,
              size: 16.sp,
            ),
            SizedBox(width: 7.w),
            Expanded(
              child: Text(
                'Pedido cancelado',
                style: TextStyle(
                  color: RoleTheme.iconDanger,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.07)),
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
                height: 20.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: segmentStart,
                      right: segmentStart,
                      top: 9.w,
                      child: Container(
                        height: 2.2.h,
                        decoration: BoxDecoration(
                          color: palette.mutedText.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                      ),
                    ),
                    Positioned(
                      left: segmentStart,
                      top: 9.w,
                      child: Container(
                        width: activeWidth,
                        height: 2.2.h,
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(labels.length, (step) {
                        final completed = step <= currentStep;
                        final current = step == currentStep;

                        return Expanded(
                          child: Center(
                            child: Container(
                              width: current ? 18.w : 16.w,
                              height: current ? 18.w : 16.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: completed
                                    ? activeColor
                                    : palette.surface,
                                border: Border.all(
                                  color: completed
                                      ? activeColor
                                      : palette.mutedText.withValues(
                                    alpha: 0.25,
                                  ),
                                  width: current ? 1.6.w : 1.4.w,
                                ),
                              ),
                              child: completed
                                  ? Icon(
                                Icons.check,
                                size: 10.5.sp,
                                color: palette.surface,
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
          SizedBox(height: 6.h),
          Row(children: labels.map(_label).toList()),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: RoleTheme.entrepreneur.mutedText,
          fontSize: 8.2.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}