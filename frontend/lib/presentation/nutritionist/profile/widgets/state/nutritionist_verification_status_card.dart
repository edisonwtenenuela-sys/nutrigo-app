import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistVerificationStatusCard extends StatelessWidget {
  final bool isVerified;

  const NutritionistVerificationStatusCard({
    super.key,
    required this.isVerified,
  });

  Color _statusColor() {
    return isVerified
        ? RoleTheme.iconValidation
        : RoleTheme.iconWarning;
  }

  IconData _statusIcon() {
    return isVerified
        ? Icons.verified_rounded
        : Icons.pending_actions_rounded;
  }

  String _statusTitle() {
    return isVerified
        ? 'Perfil aprobado por el administrador'
        : 'Revisión pendiente';
  }

  String _statusSubtitle() {
    return isVerified
        ? 'Tu perfil fue validado y todas tus funciones profesionales están disponibles.'
        : 'El administrador revisará tu información antes de habilitar validaciones y consultas.';
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    final color = _statusColor();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: color.withValues(alpha: 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              _statusIcon(),
              color: color,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _statusTitle(),
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w900,
                    color: palette.text,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _statusSubtitle(),
                  style: TextStyle(
                    fontSize: 11.4.sp,
                    height: 1.3,
                    color: palette.mutedText,
                    fontWeight: FontWeight.w600,
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