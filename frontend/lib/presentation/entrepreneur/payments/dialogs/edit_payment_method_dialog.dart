import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/payments/payment_method_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';

Future<PaymentMethodModel?> showEditPaymentMethodDialog({
  required BuildContext context,
  required PaymentMethodModel item,
}) async {
  final formController = EditPaymentMethodController(item: item);

  try {
    return await showDialog<PaymentMethodModel>(
      context: context,
      builder: (dialogContext) {
        const palette = RoleTheme.entrepreneur;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
          ),
          contentPadding: EdgeInsets.all(20.w),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit_rounded,
                  color: RoleTheme.iconColorFor(
                    Icons.edit_rounded,
                    fallback: palette.primary,
                  ),
                  size: 28.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Editar ${item.type.label}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: formController.detailController,
                cursorColor: palette.primary,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Ej: disponible para todos los pedidos',
                  filled: true,
                  fillColor: palette.primary.withValues(alpha: 0.035),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: palette.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: palette.primary,
                      width: 1.2.w,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 22.h),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42.h,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: palette.mutedText,
                          side: BorderSide(
                            color: palette.mutedText.withValues(alpha: 0.22),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: SizedBox(
                      height: 42.h,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                            formController.buildUpdatedItem(),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: palette.primary,
                          backgroundColor: palette.primary.withValues(
                            alpha: 0.055,
                          ),
                          side: BorderSide(
                            color: palette.primary.withValues(alpha: 0.18),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          'Guardar',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  } finally {
    formController.dispose();
  }
}