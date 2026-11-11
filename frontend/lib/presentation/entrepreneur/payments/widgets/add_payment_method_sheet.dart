import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/payments/payment_method_model.dart';
import 'package:emprendedor/presentation/entrepreneur/payments/helpers/payment_method_helpers.dart';
import 'package:emprendedor/presentation/entrepreneur/payments/widgets/payment_method_option_tile.dart';

class AddPaymentMethodSheet extends StatelessWidget {
  final Future<void> Function(PaymentType type) onAdd;

  const AddPaymentMethodSheet({
    super.key,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 24.h),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.08),
            blurRadius: 20.r,
            offset: Offset(0, -6.h),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            SizedBox(height: 18.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: palette.primary.withValues(alpha: 0.10),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: RoleTheme.iconColorFor(
                        Icons.account_balance_wallet_rounded,
                        fallback: palette.primary,
                      ),
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Agregar método',
                          style: TextStyle(
                            color: palette.primary,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Selecciona cómo podrán pagar tus clientes.',
                          style: TextStyle(
                            color: palette.mutedText,
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            PaymentMethodOptionTile(
              type: PaymentType.cash,
              icon: PaymentMethodHelpers.icon(PaymentType.cash),
              description: 'Pago directo al entregar el pedido.',
              onTap: () async {
                Navigator.pop(context);
                await onAdd(PaymentType.cash);
              },
            ),
            SizedBox(height: 12.h),
            PaymentMethodOptionTile(
              type: PaymentType.online,
              icon: PaymentMethodHelpers.icon(PaymentType.online),
              description: 'Pagos digitales mediante Stripe.',
              onTap: () async {
                Navigator.pop(context);
                await onAdd(PaymentType.online);
              },
            ),
          ],
        ),
      ),
    );
  }
}