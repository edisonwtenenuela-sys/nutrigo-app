import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/shared/widgets/nutrigo_logo_mark.dart';

class LoginHeader extends StatelessWidget {
  final RolePalette palette;
  final bool adminOnly;

  const LoginHeader({super.key, required this.palette, this.adminOnly = false});

  bool _isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 600;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);

    if (adminOnly) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 10.0 : 10.w),
        child: Column(
          children: [
            Text(
              'Ingreso seguro',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.text,
                fontSize: isTablet ? 25.0 : 23.sp,
                fontWeight: FontWeight.w900,
                height: 1.02,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: isTablet ? 7.0 : 7.h),
            Text(
              'Ingresa solo con correo y contraseña.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.mutedText,
                fontSize: isTablet ? 13.0 : 12.6.sp,
                fontWeight: FontWeight.w800,
                height: 1.22,
              ),
            ),
            SizedBox(height: isTablet ? 9.0 : 9.h),
            _LoginChip(label: 'Correo', palette: palette),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isTablet ? 20.0 : 17.w,
        isTablet ? 15.0 : 15.h,
        isTablet ? 20.0 : 17.w,
        isTablet ? 12.0 : 12.h,
      ),
      decoration: BoxDecoration(
        color: RoleTheme.brandBadgeBackground,
        borderRadius: BorderRadius.circular(isTablet ? 24.0 : 24.r),
        border: Border.all(color: RoleTheme.brandSoft.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.08),
            blurRadius: isTablet ? 18.0 : 18.r,
            offset: Offset(0, isTablet ? 8.0 : 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: isTablet ? 54.0 : 54.w,
            height: isTablet ? 54.0 : 54.w,
            child: Center(child: NutriGoLogoMark(size: isTablet ? 44.0 : 44.w)),
          ),
          SizedBox(width: isTablet ? 14.0 : 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  RoleTheme.brandName,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: isTablet ? 20.0 : 18.4.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                SizedBox(height: isTablet ? 4.0 : 4.h),
                Text(
                  'Accede, compra y gestiona alimentos validados.',
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: isTablet ? 12.0 : 11.5.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.24,
                  ),
                ),
                SizedBox(height: isTablet ? 6.0 : 6.h),
                Wrap(
                  spacing: isTablet ? 7.0 : 7.w,
                  runSpacing: isTablet ? 6.0 : 6.h,
                  children: [
                    _LoginChip(label: 'Correo', palette: palette),
                    _LoginChip(label: 'Teléfono', palette: palette),
                    _LoginChip(label: 'Google', palette: palette),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginChip extends StatelessWidget {
  final String label;
  final RolePalette palette;

  const _LoginChip({required this.label, required this.palette});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 10.0 : 10.w,
        vertical: isTablet ? 5.0 : 5.h,
      ),
      decoration: BoxDecoration(
        color: RoleTheme.brandChipBackground,
        borderRadius: BorderRadius.circular(isTablet ? 20.0 : 20.r),
        border: Border.all(color: RoleTheme.brandBorder),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: palette.primary,
          fontSize: isTablet ? 10.0 : 10.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
