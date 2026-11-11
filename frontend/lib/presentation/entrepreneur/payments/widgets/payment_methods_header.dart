import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class PaymentMethodsHeader extends StatelessWidget {
  final int count;

  const PaymentMethodsHeader({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 16.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(13.w),
        decoration: BoxDecoration(
          color: palette.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(17.r),
          border: Border.all(
            color: palette.primary.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 45.w,
              height: 45.w,
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: RoleTheme.iconColorFor(
                  Icons.account_balance_wallet_rounded,
                  fallback: palette.primary,
                ),
                size: 24.sp,
              ),
            ),
            SizedBox(width: 11.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pagos disponibles',
                    style: TextStyle(
                      color: palette.text,
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$count método${count == 1 ? '' : 's'} configurado${count == 1 ? '' : 's'} para tus clientes.',
                    style: TextStyle(
                      color: palette.mutedText,
                      fontSize: 11.2.sp,
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
    );
  }
}