import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/client/products/pages/index.dart';
import 'package:emprendedor/presentation/shared/widgets/buttons/app_action_button.dart';

class EmptyCartView extends StatelessWidget {
  const EmptyCartView({super.key});

  void _openProducts(BuildContext context) {
    AppNavigator.push(context, const ClientProductsPage());
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 28.h),
            child: ConstrainedBox(
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
                        color: RoleTheme.iconCart.withValues(alpha: 0.10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: RoleTheme.iconCart.withValues(alpha: 0.035),
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
                                RoleTheme.iconCart.withValues(alpha: 0.13),
                                RoleTheme.iconHealth.withValues(alpha: 0.10),
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
                                  color: RoleTheme.iconCart.withValues(
                                    alpha: 0.10,
                                  ),
                                ),
                              ),
                              child: Icon(
                                Icons.shopping_cart_checkout_rounded,
                                size: 34.sp,
                                color: RoleTheme.iconColorFor(
                                  Icons.shopping_cart_checkout_rounded,
                                  fallback: RoleTheme.iconCart,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 18.h),
                        Text(
                          'Tu carrito está vacío',
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
                          'Agrega comidas saludables validadas y prepara tu pedido en pocos pasos.',
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
                              child: _EmptyCartBenefit(
                                icon: Icons.verified_rounded,
                                label: 'Productos validados',
                                color: RoleTheme.iconValidation,
                              ),
                            ),
                            SizedBox(width: 9.w),
                            Expanded(
                              child: _EmptyCartBenefit(
                                icon: Icons.local_shipping_rounded,
                                label: 'Pedido organizado',
                                color: RoleTheme.iconOrders,
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
                    'Puedes revisar el catálogo y volver al carrito cuando agregues productos.',
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
          );
        },
      ),
    );
  }
}

class _EmptyCartBenefit extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _EmptyCartBenefit({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Container(
      constraints: BoxConstraints(minHeight: 58.h),
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 15.sp),
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