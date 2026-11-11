import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key});

  Widget _buildTopRow() {
    return Row(
      children: [
        Container(
          width: 58.w,
          height: 58.w,
          decoration: BoxDecoration(
            color: RoleTheme.brandSurface,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: RoleTheme.brandBorder),
          ),
          child: Icon(
            Icons.admin_panel_settings_rounded,
            color: RoleTheme.iconColorFor(
              Icons.admin_panel_settings_rounded,
              fallback: RoleTheme.brandPrimary,
            ),
            size: 32.sp,
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Centro de control',
                style: TextStyle(
                  color: RoleTheme.brandText,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                'Control de solicitudes, accesos y validaciones.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: RoleTheme.brandMutedText,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChipsRow() {
    return Row(
      children: [
        const _HeaderChip(icon: Icons.lock_rounded, label: 'RBAC'),
        SizedBox(width: 8.w),
        const _HeaderChip(icon: Icons.verified_rounded, label: 'Verificación'),
        SizedBox(width: 8.w),
        const _HeaderChip(icon: Icons.history_rounded, label: 'Historial'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: RoleTheme.brandBadgeBackground,
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(color: RoleTheme.brandSoft.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: RoleTheme.brandPrimary.withValues(alpha: 0.08),
            blurRadius: 24.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopRow(),
          SizedBox(height: 16.h),
          _buildChipsRow(),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: RoleTheme.brandChipBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: RoleTheme.brandBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14.sp,
              color: RoleTheme.iconColorFor(
                icon,
                fallback: RoleTheme.brandPrimary,
              ),
            ),
            SizedBox(width: 5.w),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: RoleTheme.brandText,
                    fontSize: 10.4.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
