import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class CouponSubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onPressed;

  const CouponSubmitButton({
    super.key,
    required this.isSubmitting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton.icon(
        onPressed: isSubmitting ? null : onPressed,
        icon: isSubmitting
            ? SizedBox(
          width: 17.w,
          height: 17.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: palette.primary,
          ),
        )
            : Icon(
          Icons.add_card_rounded,
          color: RoleTheme.iconColorFor(
            Icons.add_card_rounded,
            fallback: palette.primary,
          ),
          size: 18.sp,
        ),
        label: Text(
          isSubmitting ? 'Creando...' : 'Crear cupón',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          disabledForegroundColor: palette.primary.withValues(alpha: 0.55),
          backgroundColor: palette.primary.withValues(alpha: 0.055),
          disabledBackgroundColor: palette.primary.withValues(alpha: 0.035),
          side: BorderSide(
            color: palette.primary.withValues(alpha: 0.18),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}