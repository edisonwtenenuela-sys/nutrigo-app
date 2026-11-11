import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistProfileHeaderCard extends StatelessWidget {
  final bool isVerified;

  const NutritionistProfileHeaderCard({
    super.key,
    required this.isVerified,
  });

  String _title() {
    return isVerified
        ? 'Perfil profesional verificado'
        : 'Completa tu perfil profesional';
  }

  String _subtitle() {
    return isVerified
        ? 'Ya puedes gestionar validaciones y consultas.'
        : 'Tus datos serán revisados por el administrador antes de activar tus funciones.';
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.background,
            palette.primary.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.health_and_safety_rounded,
              color: RoleTheme.iconColorFor(
                Icons.health_and_safety_rounded,
                fallback: palette.primary,
              ),
              size: 28.sp,
            ),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(),
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                    color: palette.text,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _subtitle(),
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    height: 1.3,
                    color: palette.mutedText,
                    fontWeight: FontWeight.w500,
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