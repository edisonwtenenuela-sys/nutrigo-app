import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/admin/widgets/index.dart';

class AdminPanelNavigator extends StatelessWidget {
  final AdminPanelType selectedPanel;
  final ValueChanged<AdminPanelType> onChanged;

  const AdminPanelNavigator({
    super.key,
    required this.selectedPanel,
    required this.onChanged,
  });

  Widget _buildPanelOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required AdminPanelType panelType,
  }) {
    return _PanelOption(
      icon: icon,
      title: title,
      subtitle: subtitle,
      selected: selectedPanel == panelType,
      onTap: () => onChanged(panelType),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.admin;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.04),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPanelOption(
              icon: Icons.pending_actions_rounded,
              title: 'Pendientes',
              subtitle: 'Aprobaciones',
              panelType: AdminPanelType.pending,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _buildPanelOption(
              icon: Icons.history_rounded,
              title: 'Historial',
              subtitle: 'Decisiones',
              panelType: AdminPanelType.history,
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _PanelOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.admin;
    final iconColor = selected
        ? Colors.white
        : RoleTheme.iconColorFor(icon, fallback: palette.primary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          gradient: selected ? palette.headerGradient : null,
          color: selected ? null : palette.primary.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected
                ? Colors.white.withValues(alpha: 0.10)
                : palette.primary.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.18)
                    : iconColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? Colors.white : palette.text,
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.82)
                          : palette.mutedText,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}