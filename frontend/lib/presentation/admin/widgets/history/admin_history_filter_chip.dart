import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class AdminHistoryFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const AdminHistoryFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  Color _backgroundColor(RolePalette palette) {
    return selected
        ? palette.primary
        : palette.primary.withValues(alpha: 0.045);
  }

  Color _borderColor(RolePalette palette) {
    return selected
        ? palette.primary
        : palette.primary.withValues(alpha: 0.12);
  }

  Color _textColor(RolePalette palette) {
    return selected ? Colors.white : palette.primary;
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.admin;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 11.h,
        ),
        decoration: BoxDecoration(
          color: _backgroundColor(palette),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: _borderColor(palette),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _textColor(palette),
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}