import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/order_controller.dart';
import 'package:emprendedor/features/entrepreneur/controllers/update_order_status_dialog_controller.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class UpdateOrderStatusDialog extends StatefulWidget {
  final String orderId;
  final OrderStatus currentStatus;

  const UpdateOrderStatusDialog({
    super.key,
    required this.orderId,
    required this.currentStatus,
  });

  @override
  State<UpdateOrderStatusDialog> createState() =>
      _UpdateOrderStatusDialogState();
}

class _UpdateOrderStatusDialogState extends State<UpdateOrderStatusDialog> {
  late final UpdateOrderStatusDialogController _controller;

  @override
  void initState() {
    super.initState();

    _controller = UpdateOrderStatusDialogController(
      orderId: widget.orderId,
      currentStatus: widget.currentStatus,
      orderController: context.read<OrderController>(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _updateStatus() async {
    final success = await _controller.updateStatus();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    await showAppMessage(
      context,
      role: AppFeedbackRole.entrepreneur,
      type: AppFeedbackType.error,
      title: 'No se pudo actualizar',
      message: _controller.errorMessage ?? 'No se pudo actualizar.',
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return RoleTheme.iconWarning;
      case OrderStatus.confirmed:
        return RoleTheme.iconValidation;
      case OrderStatus.preparing:
        return RoleTheme.iconInfo;
      case OrderStatus.shipped:
        return RoleTheme.entrepreneur.secondary;
      case OrderStatus.delivered:
        return RoleTheme.iconValidation;
      case OrderStatus.cancelled:
        return RoleTheme.iconDanger;
    }
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Dialog(
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58.w,
                  height: 58.w,
                  decoration: BoxDecoration(
                    color: palette.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sync_alt_rounded,
                    color: RoleTheme.iconColorFor(
                      Icons.sync_alt_rounded,
                      fallback: palette.primary,
                    ),
                    size: 28.sp,
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'Actualizar estado',
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Selecciona el nuevo estado del pedido.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 18.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: palette.background,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: palette.primary.withValues(alpha: 0.10),
                    ),
                  ),
                  child: DropdownButtonFormField<OrderStatus>(
                    initialValue: _controller.selectedStatus,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: palette.primary,
                    ),
                    dropdownColor: palette.surface,
                    items: _controller.statusOptions.map((status) {
                      final color = _statusColor(status);

                      return DropdownMenuItem<OrderStatus>(
                        value: status,
                        child: Row(
                          children: [
                            Container(
                              width: 10.w,
                              height: 10.w,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              getOrderStatusDisplayString(status),
                              style: TextStyle(
                                color: palette.text,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: _controller.isUpdating
                        ? null
                        : (newValue) {
                      if (newValue == null) return;
                      _controller.updateSelectedStatus(newValue);
                    },
                  ),
                ),
                if (_controller.isUpdating) ...[
                  SizedBox(height: 18.h),
                  CircularProgressIndicator(color: palette.primary),
                ],
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _controller.isUpdating
                            ? null
                            : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: palette.mutedText,
                          side: BorderSide(
                            color: palette.mutedText.withValues(alpha: 0.25),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          'Cerrar',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.check_circle_outline,
                          size: 17.sp,
                        ),
                        label: Text(
                          'Guardar',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        onPressed:
                        _controller.isUpdating || !_controller.hasChanged
                            ? null
                            : _updateStatus,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: palette.primary.withValues(
                            alpha: 0.055,
                          ),
                          foregroundColor: palette.primary,
                          side: BorderSide(
                            color: palette.primary.withValues(alpha: 0.22),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}