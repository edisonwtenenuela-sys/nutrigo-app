import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class BusinessSetupSubmitButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onPressed;

  const BusinessSetupSubmitButton({
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
      child: ElevatedButton.icon(
        onPressed: isSaving ? null : onPressed,
        icon: isSaving
            ? SizedBox(
                width: 17.w,
                height: 17.w,
                child: const CircularProgressIndicator(strokeWidth: 2.2),
              )
            : const Icon(Icons.check_circle_rounded),
        label: Text(
          isSaving ? 'Guardando...' : 'Completar registro',
          style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w900),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: palette.primary,
          backgroundColor: palette.primary.withValues(alpha: 0.10),
          elevation: 0,
          side: BorderSide(color: palette.primary.withValues(alpha: 0.22)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
        ),
      ),
    );
  }
}








