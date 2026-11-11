import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

Future<String?> showRejectProductDialog({required BuildContext context}) {
  return showDialog<String>(
    context: context,
    builder: (_) => const _RejectProductDialog(),
  );
}

class _RejectProductDialog extends StatefulWidget {
  const _RejectProductDialog();

  @override
  State<_RejectProductDialog> createState() => _RejectProductDialogState();
}

class _RejectProductDialogState extends State<_RejectProductDialog> {
  static const _title = 'Rechazar producto';
  static const _description =
      'Indica el motivo para que el emprendedor pueda corregir la información del producto.';
  static const _hint = 'Ej: imagen borrosa o ingredientes incompletos.';

  final TextEditingController _commentController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    final comment = _commentController.text.trim();

    if (comment.isEmpty) {
      setState(() => _errorText = 'Ingresa un motivo de rechazo.');
      return;
    }

    Navigator.of(context).pop(comment);
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    final radius = BorderRadius.circular(16.r);

    return AlertDialog(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      contentPadding: EdgeInsets.all(20.w),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58.w,
              height: 58.w,
              decoration: BoxDecoration(
                color: RoleTheme.iconDanger.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cancel_outlined,
                color: RoleTheme.iconDanger,
                size: 31.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              _title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: palette.text,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5.sp,
                height: 1.35,
                color: palette.mutedText,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _commentController,
              maxLines: 4,
              minLines: 3,
              cursorColor: RoleTheme.iconDanger,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: palette.text,
              ),
              onChanged: (_) {
                if (_errorText != null) setState(() => _errorText = null);
              },
              decoration: InputDecoration(
                labelText: 'Motivo del rechazo',
                hintText: _hint,
                errorText: _errorText,
                alignLabelWithHint: true,
                filled: true,
                fillColor: palette.background,
                labelStyle: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: RoleTheme.iconDanger,
                ),
                hintStyle: TextStyle(
                  fontSize: 12.sp,
                  color: palette.mutedText.withValues(alpha: 0.72),
                ),
                border: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide(
                    color: palette.primary.withValues(alpha: 0.10),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide(
                    color: palette.primary.withValues(alpha: 0.10),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide(
                    color: RoleTheme.iconDanger.withValues(alpha: 0.70),
                    width: 1.3.w,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide(
                    color: RoleTheme.iconDanger.withValues(alpha: 0.65),
                    width: 1.2.w,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide(
                    color: RoleTheme.iconDanger,
                    width: 1.3.w,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42.h,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: palette.text,
                        side: BorderSide(
                          color: palette.primary.withValues(alpha: 0.14),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: SizedBox(
                    height: 42.h,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RoleTheme.iconDanger,
                        foregroundColor: palette.surface,
                        disabledBackgroundColor:
                        RoleTheme.iconDanger.withValues(alpha: 0.35),
                        disabledForegroundColor:
                        palette.surface.withValues(alpha: 0.72),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'Rechazar',
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
      ),
    );
  }
}