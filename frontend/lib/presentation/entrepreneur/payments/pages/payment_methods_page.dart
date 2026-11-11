import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/payments/payment_method_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';
import 'package:emprendedor/presentation/entrepreneur/payments/dialogs/delete_payment_method_dialog.dart';
import 'package:emprendedor/presentation/entrepreneur/payments/dialogs/edit_payment_method_dialog.dart';
import 'package:emprendedor/presentation/entrepreneur/payments/helpers/payment_method_helpers.dart';
import 'package:emprendedor/presentation/entrepreneur/payments/widgets/add_payment_method_sheet.dart';
import 'package:emprendedor/presentation/entrepreneur/payments/widgets/payment_method_card.dart';
import 'package:emprendedor/presentation/entrepreneur/payments/widgets/payment_method_empty_state.dart';
import 'package:emprendedor/presentation/entrepreneur/payments/widgets/payment_methods_header.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  final PaymentMethodsScreenController _screenController =
  PaymentMethodsScreenController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _screenController.load(context.read<PaymentMethodController>());
    });
  }

  Future<void> _refresh() async {
    await _screenController.refresh(context.read<PaymentMethodController>());
  }

  Future<void> _showActionResult(PaymentMethodActionResult result) {
    return showAppMessage(
      context,
      role: AppFeedbackRole.entrepreneur,
      type: result.success ? AppFeedbackType.success : AppFeedbackType.error,
      title: result.title,
      message: result.message,
    );
  }

  Future<void> _addPaymentMethod(PaymentType type) async {
    final result = await _screenController.addPaymentMethod(
      context.read<PaymentMethodController>(),
      type,
    );

    if (!mounted) return;
    await _showActionResult(result);
  }

  Future<void> _deletePaymentMethod(
      PaymentMethodController controller,
      PaymentMethodModel item,
      ) async {
    final confirm = await showDeletePaymentMethodDialog(
      context: context,
      item: item,
    );

    if (!mounted || !confirm) return;

    final result = await _screenController.deletePaymentMethod(
      controller,
      item,
    );

    if (!mounted) return;
    await _showActionResult(result);
  }

  Future<void> _editPaymentMethod(
      PaymentMethodController controller,
      PaymentMethodModel item,
      ) async {
    final updatedItem = await showEditPaymentMethodDialog(
      context: context,
      item: item,
    );

    if (!mounted || updatedItem == null) return;

    final result = await _screenController.updatePaymentMethod(
      controller,
      updatedItem,
    );

    if (!mounted) return;
    await _showActionResult(result);
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: RoleTheme.entrepreneur.text.withValues(alpha: 0.28),
      isScrollControlled: true,
      builder: (_) => AddPaymentMethodSheet(onAdd: _addPaymentMethod),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;
    final controller = context.watch<PaymentMethodController>();

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        surfaceTintColor: palette.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Métodos de pago',
          style: TextStyle(
            color: palette.text,
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: _buildBody(controller),
      floatingActionButton: controller.paymentMethods.isEmpty
          ? null
          : _buildFloatingActionButton(palette),
    );
  }

  Widget _buildFloatingActionButton(RolePalette palette) {
    return FloatingActionButton.extended(
      heroTag: 'paymentMethodFab',
      elevation: 0,
      backgroundColor: palette.primary.withValues(alpha: 0.055),
      foregroundColor: palette.primary,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: palette.primary.withValues(alpha: 0.18)),
        borderRadius: BorderRadius.circular(18.r),
      ),
      onPressed: _showAddOptions,
      icon: Icon(Icons.add_rounded, size: 20.sp),
      label: Text(
        'Agregar método',
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildBody(PaymentMethodController controller) {
    const palette = RoleTheme.entrepreneur;
    final uiState = _screenController.resolveUiState(controller);

    if (uiState == PaymentMethodsUiState.loading) {
      return Center(child: CircularProgressIndicator(color: palette.primary));
    }

    if (uiState == PaymentMethodsUiState.error) {
      return _buildErrorState(controller, palette);
    }

    if (uiState == PaymentMethodsUiState.empty) {
      return RefreshIndicator(
        color: palette.primary,
        onRefresh: _refresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 24.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: PaymentMethodEmptyState(onAdd: _showAddOptions),
                ),
              ),
            );
          },
        ),
      );
    }

    return _buildPaymentMethodsList(controller, palette);
  }

  Widget _buildErrorState(
      PaymentMethodController controller,
      RolePalette palette,
      ) {
    return RefreshIndicator(
      color: palette.primary,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(24.w),
        children: [
          SizedBox(height: 130.h),
          Icon(
            Icons.error_outline_rounded,
            color: RoleTheme.iconDanger,
            size: 58.sp,
          ),
          SizedBox(height: 14.h),
          Text(
            controller.errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RoleTheme.iconDanger,
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList(
      PaymentMethodController controller,
      RolePalette palette,
      ) {
    return RefreshIndicator(
      color: palette.primary,
      onRefresh: _refresh,
      child: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 96.h),
        children: [
          PaymentMethodsHeader(count: controller.paymentMethods.length),
          SizedBox(height: 14.h),
          ...controller.paymentMethods.map((item) {
            return PaymentMethodCard(
              item: item,
              details: PaymentMethodHelpers.formatDetails(item),
              icon: PaymentMethodHelpers.icon(item.type),
              onEdit: () => _editPaymentMethod(controller, item),
              onDelete: item.id == null
                  ? null
                  : () => _deletePaymentMethod(controller, item),
            );
          }),
        ],
      ),
    );
  }
}