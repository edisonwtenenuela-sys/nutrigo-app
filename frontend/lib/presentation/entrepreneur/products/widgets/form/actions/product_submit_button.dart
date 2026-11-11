import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class ProductSubmitButton extends StatelessWidget {
  final bool isLoading;
  final bool isEditing;
  final String? loadingLabel;
  final VoidCallback onPressed;

  const ProductSubmitButton({
    super.key,
    required this.isLoading,
    required this.isEditing,
    this.loadingLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return SizedBox(
      width: double.infinity,
      height: 46.h,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? Icon(Icons.hourglass_top_rounded, size: 17.sp)
            : Icon(
                isEditing ? Icons.sync_rounded : Icons.add_box_rounded,
                size: 18.sp,
              ),
        label: Text(
          isLoading
              ? loadingLabel ?? 'Enviando...'
              : isEditing
              ? 'Reenviar a validación'
              : 'Enviar a validación',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12.8.sp, fontWeight: FontWeight.w900),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          backgroundColor: palette.primary.withValues(alpha: 0.055),
          disabledForegroundColor: palette.primary.withValues(alpha: 0.45),
          disabledBackgroundColor: palette.primary.withValues(alpha: 0.04),
          side: BorderSide(color: palette.primary.withValues(alpha: 0.20)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}
