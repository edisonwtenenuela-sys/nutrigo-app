import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class BusinessProfileSubmitButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onPressed;

  const BusinessProfileSubmitButton({
    super.key,
    required this.isSaving,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton.icon(
        onPressed: isSaving ? null : onPressed,
        icon: isSaving
            ? SizedBox(
                width: 19.w,
                height: 19.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: palette.primary,
                ),
              )
            : Icon(Icons.save_rounded, size: 18.sp),
        label: Text(
          isSaving ? 'Guardando...' : 'Guardar cambios',
          style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w900),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          backgroundColor: palette.primary.withValues(alpha: 0.055),
          side: BorderSide(color: palette.primary.withValues(alpha: 0.18)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}








