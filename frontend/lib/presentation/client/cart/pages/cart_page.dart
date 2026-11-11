import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/cart_item_model.dart';
import 'package:emprendedor/data/repositories/shared/order_repository.dart';
import 'package:emprendedor/features/client/controllers/cart_checkout_controller.dart';
import 'package:emprendedor/features/client/controllers/cart_controller.dart';
import 'package:emprendedor/features/client/controllers/client_location_picker_controller.dart';
import 'package:emprendedor/presentation/client/cart/pages/select_location_page.dart';
import 'package:emprendedor/presentation/client/cart/widgets/index.dart';
import 'package:emprendedor/presentation/client/orders/pages/order_detail_page.dart';
import 'package:emprendedor/presentation/client/products/pages/business_store_page.dart';
import 'package:emprendedor/presentation/shared/widgets/buttons/app_action_button.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late final CartCheckoutController _checkoutController;
  final OrderRepository _orderRepository = OrderRepository();
  _CheckoutStep _currentStep = _CheckoutStep.cart;
  bool _isCompletingCheckout = false;

  _CartUiState _resolveUiState(CartController cart) {
    if (cart.items.isEmpty) return _CartUiState.empty;
    return _CartUiState.content;
  }

  @override
  void initState() {
    super.initState();
    _checkoutController = CartCheckoutController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkoutController.loadDefaultLocationIfNeeded();
    });
  }

  @override
  void dispose() {
    _checkoutController.dispose();
    super.dispose();
  }

  void _showFeedback(CartFeedbackMessage feedback) {
    showAppMessage(
      context,
      role: AppFeedbackRole.client,
      type: feedback.isError ? AppFeedbackType.error : AppFeedbackType.success,
      title:
          feedback.title ??
          (feedback.isError ? 'No se pudo continuar' : 'Listo'),
      message: feedback.message,
    );
  }

  Future<void> _removeItemAnimated(
    CartController cart,
    CartItemModel item,
  ) async {
    final feedback = await _checkoutController.removeItemAnimated(cart, item);
    if (!mounted || feedback == null) return;
    _showFeedback(feedback);
  }

  Future<void> _applyCoupon() async {
    final feedback = await _checkoutController.applyCoupon(
      context.read<CartController>(),
    );
    if (!mounted) return;
    _showFeedback(feedback);
  }

  void _removeCoupon() {
    final feedback = _checkoutController.removeCoupon(
      context.read<CartController>(),
    );
    _showFeedback(feedback);
  }

  void _showProcessingDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ProcessingPaymentDialog(),
    );
  }

  void _closeProcessingDialogIfNeeded() {
    if (!_checkoutController.isPaymentFlowActive || !mounted) return;

    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) navigator.pop();
  }

  Future<void> _confirmOrder() async {
    if (_isCompletingCheckout) return;

    final result = await _checkoutController.confirmOrder(
      cart: context.read<CartController>(),
      showProcessingDialog: _showProcessingDialog,
      closeProcessingDialog: _closeProcessingDialogIfNeeded,
      onCompletingCheckout: () {
        if (!mounted || _isCompletingCheckout) return;
        setState(() => _isCompletingCheckout = true);
      },
      onFeedback: (feedback) {
        if (!mounted) return;
        _showFeedback(feedback);
      },
    );

    if (!mounted) return;

    if (result == null) {
      setState(() => _isCompletingCheckout = false);
      return;
    }

    _openCreatedOrder(result);
  }

  Future<void> _selectLocation() async {
    final result = await AppNavigator.push<SelectedLocationResult>(
      context,
      SelectLocationPage(
        initialAddress: _checkoutController.addressController.text,
        initialLatitude: _checkoutController.latitude,
        initialLongitude: _checkoutController.longitude,
      ),
    );

    if (!mounted || result == null) return;

    _checkoutController.updateLocation(
      address: result.address,
      latitude: result.latitude,
      longitude: result.longitude,
    );

    _showFeedback(
      const CartFeedbackMessage(
        message: 'Ubicación seleccionada correctamente.',
        title: 'Ubicación guardada',
      ),
    );
  }

  void _openCreatedOrder(CartCheckoutResult result) {
    _showFeedback(
      CartFeedbackMessage(message: result.message, title: 'Pedido confirmado'),
    );

    Navigator.of(context).pushAndRemoveUntil(
      AppNavigator.route(
        OrderDetailPage(
          order: result.order,
          formattedDate: DateFormat(
            'dd MMM yyyy',
          ).format(result.order.createdAt.toDate()),
        ),
      ),
      (route) => route.isFirst,
    );
  }

  AppBar _buildAppBar(RolePalette palette) {
    return AppBar(
      backgroundColor: palette.background,
      elevation: 0,
      centerTitle: true,
      leadingWidth: 58.w,
      leading: Padding(
        padding: EdgeInsets.only(left: 10.w),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: palette.text,
            size: 22.sp,
          ),
          onPressed: () {
            if (_currentStep == _CheckoutStep.summary) {
              setState(() => _currentStep = _CheckoutStep.cart);
              return;
            }
            Navigator.of(context).maybePop();
          },
        ),
      ),
      title: Text(
        'Mi carrito',
        style: TextStyle(
          color: palette.text,
          fontWeight: FontWeight.w900,
          fontSize: 19.sp,
        ),
      ),
    );
  }

  Widget _buildStepIndicator(RolePalette palette) {
    final isCart = _currentStep == _CheckoutStep.cart;

    return Container(
      margin: EdgeInsets.fromLTRB(24.w, 0, 24.w, 10.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StepTab(
              number: '1',
              label: 'Carrito',
              active: isCart,
              completed: !isCart,
              onTap: isCart
                  ? null
                  : () => setState(() => _currentStep = _CheckoutStep.cart),
            ),
          ),
          Expanded(
            child: _StepTab(
              number: '2',
              label: 'Resumen',
              active: !isCart,
              completed: false,
              onTap: null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openCurrentBusinessStore(CartController cart) async {
    final businessId = cart.currentBusinessId?.trim();
    if (businessId == null || businessId.isEmpty) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      return;
    }

    final summary = await _orderRepository.getBusinessSummaryForOrder(
      businessId,
    );

    if (!mounted) return;

    AppNavigator.push(
      context,
      BusinessStorePage(businessId: businessId, initialSummary: summary),
    );
  }

  Widget _buildCartItemsList(CartController cart) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        final item = cart.items[index];
        final isRemoving = _checkoutController.removingItems.contains(
          item.productId,
        );

        return CartItemCard(
          item: item,
          isRemoving: isRemoving,
          isProcessing: cart.isProcessingOrder,
          onIncrease: () async {
            await cart.increaseQuantity(item.productId);
          },
          onDecrease: () async {
            await cart.decreaseQuantity(item.productId);
          },
          onRemove: () => _removeItemAnimated(cart, item),
        );
      },
    );
  }

  Widget _buildAddMoreProductsButton(RolePalette palette, CartController cart) {
    return OutlinedButton.icon(
      onPressed: () => _openCurrentBusinessStore(cart),
      icon: Icon(Icons.add_rounded, size: 18.sp),
      label: Text(
        'Agregar más productos',
        style: TextStyle(fontSize: 12.8.sp, fontWeight: FontWeight.w900),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 44.h),
        foregroundColor: palette.primary,
        side: BorderSide(color: palette.primary.withValues(alpha: 0.45)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13.r),
        ),
      ),
    );
  }

  Widget _buildCartStep(CartController cart, RolePalette palette) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(18.w, 2.h, 18.w, 12.h),
            child: Column(
              children: [
                _buildCartItemsList(cart),
                SizedBox(height: 4.h),
                _buildAddMoreProductsButton(palette, cart),
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 18.h),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26.r),
              topRight: Radius.circular(26.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 22.r,
                offset: Offset(0, -8.h),
              ),
            ],
          ),
          child: Column(
            children: [
              CartTotalSummary(
                subtotal: cart.subtotal,
                discountAmount: cart.discountAmount,
                finalTotal: cart.finalTotal,
                itemCount: cart.itemCount,
                discountLabel: cart.discountLabel,
              ),
              SizedBox(height: 12.h),
              ClientActionButton(
                label: 'Continuar al resumen',
                icon: Icons.arrow_forward_rounded,
                height: 46.h,
                fontSize: 13.5.sp,
                isLoading: false,
                onPressed: () =>
                    setState(() => _currentStep = _CheckoutStep.summary),
              ),
              SizedBox(height: 10.h),
              _SecurePaymentLabel(palette: palette),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStep(CartController cart) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 18.h),
      child: CartCheckoutPanel(
        addressController: _checkoutController.addressController,
        couponController: _checkoutController.couponController,
        isProcessingOrder: cart.isProcessingOrder,
        isApplyingCoupon: cart.isApplyingCoupon,
        subtotal: cart.subtotal,
        discountAmount: cart.discountAmount,
        finalTotal: cart.finalTotal,
        discountLabel: cart.discountLabel,
        appliedCouponCode: cart.hasCouponApplied
            ? cart.appliedCouponCode
            : null,
        couponMessage: cart.couponMessage,
        couponNotice: cart.couponNotice,
        latitude: _checkoutController.latitude,
        longitude: _checkoutController.longitude,
        selectedPaymentMethod: _checkoutController.selectedPaymentMethod,
        paymentMethods: _checkoutController.paymentMethods,
        onSelectLocation: _selectLocation,
        onConfirmOrder: _confirmOrder,
        onApplyCoupon: _applyCoupon,
        onRemoveCoupon: _removeCoupon,
        onPaymentMethodChanged: _checkoutController.updatePaymentMethod,
      ),
    );
  }

  Widget _buildCompletingCheckoutView(RolePalette palette) {
    return SafeArea(
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 28.w),
          padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 24.h),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: palette.primary.withValues(alpha: 0.08),
                blurRadius: 22.r,
                offset: Offset(0, 9.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 34.w,
                height: 34.w,
                child: CircularProgressIndicator(
                  strokeWidth: 3.w,
                  color: palette.primary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Finalizando tu pedido',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Estamos abriendo el detalle para que puedas revisar el seguimiento.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.mutedText,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartBody(CartController cart) {
    const palette = RoleTheme.client;

    if (_isCompletingCheckout ||
        (cart.isProcessingOrder && cart.items.isEmpty)) {
      return _buildCompletingCheckoutView(palette);
    }

    switch (_resolveUiState(cart)) {
      case _CartUiState.empty:
        if (_currentStep != _CheckoutStep.cart) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _currentStep = _CheckoutStep.cart);
          });
        }
        return const EmptyCartView();
      case _CartUiState.content:
        return SafeArea(
          child: Column(
            children: [
              _buildStepIndicator(palette),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _currentStep == _CheckoutStep.cart
                      ? _buildCartStep(cart, palette)
                      : _buildSummaryStep(cart),
                ),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    const palette = RoleTheme.client;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: _buildAppBar(palette),
      body: ListenableBuilder(
        listenable: _checkoutController,
        builder: (context, _) => _buildCartBody(cart),
      ),
    );
  }
}

class _StepTab extends StatelessWidget {
  final String number;
  final String label;
  final bool active;
  final bool completed;
  final VoidCallback? onTap;

  const _StepTab({
    required this.number,
    required this.label,
    required this.active,
    required this.completed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final selected = active || completed;
    final foreground = selected ? Colors.white : palette.mutedText;
    final background = selected ? palette.primary : Colors.transparent;

    return InkWell(
      borderRadius: BorderRadius.circular(15.r),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 38.h,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 19.r,
              height: 19.r,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.22)
                    : const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: completed
                  ? Icon(Icons.check_rounded, size: 13.sp, color: foreground)
                  : Text(
                      number,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurePaymentLabel extends StatelessWidget {
  final RolePalette palette;

  const _SecurePaymentLabel({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

enum _CartUiState { empty, content }

enum _CheckoutStep { cart, summary }
