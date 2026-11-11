import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class PromotionSubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final bool isEditing;
  final VoidCallback onPressed;

  const PromotionSubmitButton({
    super.key,
    required this.isSubmitting,
    required this.isEditing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final icon = isEditing ? Icons.sync_rounded : Icons.add_box_rounded;

    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: FilledButton.icon(
        onPressed: isSubmitting ? null : onPressed,
        icon: isSubmitting
            ? SizedBox(
          width: 16.w,
          height: 16.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: palette.surface,
          ),
        )
            : Icon(
          icon,
          color: palette.surface,
          size: 17.sp,
        ),
        label: Text(
          isSubmitting
              ? 'Guardando...'
              : isEditing
              ? 'Actualizar promoción'
              : 'Crear promoción',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.3.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        style: FilledButton.styleFrom(
          foregroundColor: palette.surface,
          backgroundColor: palette.primary,
          disabledForegroundColor: palette.surface.withValues(alpha: 0.82),
          disabledBackgroundColor: palette.primary.withValues(alpha: 0.55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
        ),
      ),
    );
  }
}