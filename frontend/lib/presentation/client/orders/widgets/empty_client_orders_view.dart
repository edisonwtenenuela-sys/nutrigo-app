import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/client/products/pages/index.dart';
import 'package:emprendedor/presentation/shared/widgets/buttons/app_action_button.dart';

class EmptyClientOrdersView extends StatelessWidget {
  const EmptyClientOrdersView({super.key});

  void _openProducts(BuildContext context) {
    AppNavigator.push(context, const ClientProductsPage());
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 28.h),
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 56.h,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(18.w, 22.h, 18.w, 18.h),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: RoleTheme.iconOrders.withValues(alpha: 0.10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: RoleTheme.iconOrders.withValues(alpha: 0.035),
                          blurRadius: 22.r,
                          offset: Offset(0, 10.h),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 104.w,
                          height: 104.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                RoleTheme.iconOrders.withValues(alpha: 0.13),
                                RoleTheme.iconCart.withValues(alpha: 0.10),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 66.w,
                              height: 66.w,
                              decoration: BoxDecoration(
                                color: palette.surface,
                                borderRadius: BorderRadius.circular(22.r),
                                border: Border.all(
                                  color: RoleTheme.iconOrders.withValues(
                                    alpha: 0.10,
                                  ),
                                ),
                              ),
                              child: Icon(
                                Icons.receipt_long_rounded,
                                size: 34.sp,
                                color: RoleTheme.iconColorFor(
                                  Icons.receipt_long_rounded,
                                  fallback: RoleTheme.iconOrders,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 18.h),
                        Text(
                          'Aún no tienes pedidos',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: palette.text,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Cuando compres en NutriGo, aquí verás el estado, total y detalle de cada pedido.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: palette.mutedText,
                            height: 1.35,
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 18.h),
                        Row(
                          children: [
                            Expanded(
                              child: _EmptyOrderBenefit(
                                icon: Icons.fact_check_rounded,
                                label: 'Seguimiento del pedido',
                                color: RoleTheme.iconOrders,
                              ),
                            ),
                            SizedBox(width: 9.w),
                            Expanded(
                              child: _EmptyOrderBenefit(
                                icon: Icons.payments_rounded,
                                label: 'Total y pagos claros',
                                color: RoleTheme.iconPayments,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        ClientActionButton(
                          label: 'Explorar comidas',
                          icon: Icons.restaurant_menu_rounded,
                          height: 48.h,
                          fontSize: 13.5.sp,
                          onPressed: () => _openProducts(context),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'Desliza hacia abajo para actualizar tus pedidos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.mutedText,
                      fontSize: 11.5.sp,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyOrderBenefit extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _EmptyOrderBenefit({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final semanticIconColor = RoleTheme.iconColorFor(
      icon,
      fallback: color,
    );

    return Container(
      constraints: BoxConstraints(minHeight: 58.h),
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: semanticIconColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: semanticIconColor.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: semanticIconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: semanticIconColor,
              size: 15.sp,
            ),
          ),
          SizedBox(width: 7.w),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.text,
                fontSize: 10.5.sp,
                height: 1.15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}