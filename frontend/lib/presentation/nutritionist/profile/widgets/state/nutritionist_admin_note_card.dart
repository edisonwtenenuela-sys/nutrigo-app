import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistAdminNoteCard extends StatelessWidget {
  const NutritionistAdminNoteCard({super.key});

  static const _noteText =
      'Después de guardar tu perfil, el administrador revisará tus credenciales y aprobará tu acceso profesional.';

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.admin_panel_settings_rounded,
            color: RoleTheme.iconColorFor(
              Icons.admin_panel_settings_rounded,
              fallback: palette.primary,
            ),
            size: 21.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              _noteText,
              style: TextStyle(
                fontSize: 11.8.sp,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: palette.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}