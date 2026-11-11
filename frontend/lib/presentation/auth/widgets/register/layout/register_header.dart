import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/shared/widgets/nutrigo_logo_mark.dart';

class RegisterHeader extends StatelessWidget {
  final String selectedRole;

  const RegisterHeader({super.key, required this.selectedRole});

  RolePalette get _palette {
    switch (selectedRole) {
      case 'cliente':
        return RoleTheme.client;
      case 'nutricionista':
        return RoleTheme.nutritionist;
      case 'emprendedor':
      default:
        return RoleTheme.entrepreneur;
    }
  }

  String get _title {
    switch (selectedRole) {
      case 'cliente':
        return 'Registro de usuario';
      case 'nutricionista':
        return 'Registro profesional';
      case 'emprendedor':
      default:
        return 'Registro de negocio';
    }
  }

  String get _subtitle {
    switch (selectedRole) {
      case 'cliente':
        return 'Crea tu cuenta para comprar y agendar citas.';
      case 'nutricionista':
        return 'Tu perfil será revisado antes de validar productos.';
      case 'emprendedor':
      default:
        return 'Tu perfil será revisado antes de publicar en NutriGo.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 11.h),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 18.r,
            offset: Offset(0, 9.h),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48.w,
            height: 48.w,
            child: Center(child: NutriGoLogoMark(size: 42.w)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  _subtitle,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 10.7.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
