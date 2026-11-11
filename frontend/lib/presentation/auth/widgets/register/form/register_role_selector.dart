import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class RegisterRoleSelector extends StatelessWidget {
  final String selectedRole;
  final bool isLoading;
  final ValueChanged<String> onRoleChanged;

  const RegisterRoleSelector({
    super.key,
    required this.selectedRole,
    required this.isLoading,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RoleTile(
            value: 'emprendedor',
            selectedRole: selectedRole,
            isLoading: isLoading,
            icon: Icons.storefront_rounded,
            label: 'Emprendedor',
            onRoleChanged: onRoleChanged,
          ),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: _RoleTile(
            value: 'cliente',
            selectedRole: selectedRole,
            isLoading: isLoading,
            icon: Icons.shopping_bag_rounded,
            label: 'Cliente',
            onRoleChanged: onRoleChanged,
          ),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: _RoleTile(
            value: 'nutricionista',
            selectedRole: selectedRole,
            isLoading: isLoading,
            icon: Icons.medical_services_rounded,
            label: 'Nutricionista',
            onRoleChanged: onRoleChanged,
          ),
        ),
      ],
    );
  }
}

class _RoleTile extends StatelessWidget {
  final String value;
  final String selectedRole;
  final bool isLoading;
  final IconData icon;
  final String label;
  final ValueChanged<String> onRoleChanged;

  const _RoleTile({
    required this.value,
    required this.selectedRole,
    required this.isLoading,
    required this.icon,
    required this.label,
    required this.onRoleChanged,
  });

  RolePalette get _palette {
    switch (value) {
      case 'cliente':
        return RoleTheme.client;
      case 'nutricionista':
        return RoleTheme.nutritionist;
      case 'emprendedor':
      default:
        return RoleTheme.entrepreneur;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = selectedRole == value;
    final palette = _palette;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: isLoading ? null : () => onRoleChanged(value),
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: BoxConstraints(minHeight: 58.h),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: selected
                ? palette.primary.withValues(alpha: 0.12)
                : palette.surface.withValues(alpha: 0.74),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: selected
                  ? palette.primary.withValues(alpha: 0.48)
                  : palette.primary.withValues(alpha: 0.09),
              width: selected ? 1.3.w : 1.w,
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 12.r,
                offset: Offset(0, 6.h),
              ),
            ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? palette.primary
                      : palette.primary.withValues(alpha: 0.09),
                ),
                child: Icon(
                  icon,
                  color: selected
                      ? palette.surface
                      : RoleTheme.iconColorFor(icon, fallback: palette.primary),
                  size: 13.5.sp,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? palette.primary : palette.text,
                  fontSize: 10.2.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}