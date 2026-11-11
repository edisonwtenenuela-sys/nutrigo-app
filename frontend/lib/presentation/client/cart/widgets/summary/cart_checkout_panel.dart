import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/client/cart/widgets/inputs/index.dart';
import 'package:emprendedor/presentation/client/cart/widgets/summary/cart_total_summary.dart';
import 'package:emprendedor/presentation/shared/widgets/buttons/app_action_button.dart';

class CartCheckoutPanel extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController couponController;

  final bool isProcessingOrder;
  final bool isApplyingCoupon;

  final double subtotal;
  final double discountAmount;
  final double finalTotal;
  final String? discountLabel;

  final String? appliedCouponCode;
  final String? couponMessage;
  final String? couponNotice;

  final double? latitude;
  final double? longitude;

  final String? selectedPaymentMethod;
  final List<String> paymentMethods;

  final VoidCallback onSelectLocation;
  final VoidCallback onConfirmOrder;
  final VoidCallback onApplyCoupon;
  final VoidCallback onRemoveCoupon;

  final ValueChanged<String?> onPaymentMethodChanged;

  const CartCheckoutPanel({
    super.key,
    required this.addressController,
    required this.couponController,
    required this.isProcessingOrder,
    required this.isApplyingCoupon,
    required this.subtotal,
    required this.discountAmount,
    required this.finalTotal,
    required this.discountLabel,
    required this.appliedCouponCode,
    required this.couponMessage,
    required this.couponNotice,
    required this.latitude,
    required this.longitude,
    required this.selectedPaymentMethod,
    required this.paymentMethods,
    required this.onSelectLocation,
    required this.onConfirmOrder,
    required this.onApplyCoupon,
    required this.onRemoveCoupon,
    required this.onPaymentMethodChanged,
  });

  bool get hasDiscount => discountAmount > 0;

  Widget _buildLocationAction(RolePalette palette) {
    final hasLocation = latitude != null && longitude != null;

    return Row(
      children: [
        Expanded(
          child: Text(
            hasLocation
                ? 'Ubicación seleccionada'
                : 'Puedes elegirla en el mapa',
            style: TextStyle(
              fontSize: 11.2.sp,
              color: hasLocation ? RoleTheme.iconLocation : palette.mutedText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: isProcessingOrder ? null : onSelectLocation,
          icon: Icon(
            Icons.map_outlined,
            color: RoleTheme.iconColorFor(
              Icons.map_outlined,
              fallback: RoleTheme.iconLocation,
            ),
            size: 17.sp,
          ),
          label: Text(
            'Elegir en mapa',
            style: TextStyle(
              color: RoleTheme.iconLocation,
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required RolePalette palette,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    final sectionColor = RoleTheme.iconColorFor(
      icon,
      fallback: RoleTheme.iconInfo,
    );

    return Container(
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: sectionColor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: sectionColor.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CartPanelIcon(icon: icon, color: sectionColor),
              SizedBox(width: 9.w),
              Text(
                title,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: 11.h),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Column(
      children: [
        _buildSection(
          palette: palette,
          icon: Icons.location_on_outlined,
          title: 'Dirección de envío',
          child: Column(
            children: [
              CartStyledTextField(
                controller: addressController,
                enabled: !isProcessingOrder,
                label: 'Dirección de envío',
                icon: Icons.location_on_outlined,
              ),
              SizedBox(height: 6.h),
              _buildLocationAction(palette),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _buildSection(
          palette: palette,
          icon: Icons.payment_rounded,
          title: 'Método de pago',
          child: DropdownButtonFormField<String>(
            initialValue: selectedPaymentMethod,
            decoration: cartInputDecoration(
              label: 'Método de pago',
              icon: Icons.credit_card_rounded,
            ),
            items: paymentMethods.map((method) {
              return DropdownMenuItem(
                value: method,
                child: Text(
                  method,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
            onChanged: isProcessingOrder ? null : onPaymentMethodChanged,
          ),
        ),
        SizedBox(height: 12.h),
        CartCouponBox(
          couponController: couponController,
          isProcessingOrder: isProcessingOrder,
          isApplyingCoupon: isApplyingCoupon,
          appliedCouponCode: appliedCouponCode,
          couponMessage: couponMessage,
          couponNotice: couponNotice,
          hasDiscount: hasDiscount,
          onApplyCoupon: onApplyCoupon,
          onRemoveCoupon: onRemoveCoupon,
        ),
        SizedBox(height: 12.h),
        CartTotalSummary(
          subtotal: subtotal,
          discountAmount: discountAmount,
          finalTotal: finalTotal,
          discountLabel: discountLabel,
        ),
        SizedBox(height: 12.h),
        ClientActionButton(
          label: 'Confirmar pedido',
          loadingLabel: 'Procesando...',
          icon: Icons.lock_outline_rounded,
          height: 46.h,
          fontSize: 13.5.sp,
          isLoading: isProcessingOrder,
          onPressed: onConfirmOrder,
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 14.sp,
              color: RoleTheme.iconSecurity,
            ),
            SizedBox(width: 5.w),
            Text(
              'Pago 100% seguro',
              style: TextStyle(
                color: palette.mutedText,
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
