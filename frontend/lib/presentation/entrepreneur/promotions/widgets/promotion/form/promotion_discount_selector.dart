import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/promotions/promotion_model.dart';

class PromotionDiscountSelector extends StatelessWidget {
  final DiscountType selectedType;
  final bool isSubmitting;
  final ValueChanged<DiscountType> onChanged;

  const PromotionDiscountSelector({
    super.key,
    required this.selectedType,
    required this.isSubmitting,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = !isSubmitting;

    return Row(
      children: [
        Expanded(
          child: _DiscountTypeChip(
            label: 'Porcentaje',
            icon: Icons.percent_rounded,
            selected: selectedType == DiscountType.percentage,
            enabled: enabled,
            onTap: () => onChanged(DiscountType.percentage),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _DiscountTypeChip(
            label: 'Monto fijo',
            icon: Icons.attach_money_rounded,
            selected: selectedType == DiscountType.fixed,
            enabled: enabled,
            onTap: () => onChanged(DiscountType.fixed),
          ),
        ),
      ],
    );
  }
}

class _DiscountTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _DiscountTypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final text = label.trim().isNotEmpty ? label.trim() : 'Opción';
    final iconColor = !enabled
        ? palette.mutedText
        : selected
        ? RoleTheme.iconColorFor(icon, fallback: palette.primary)
        : palette.mutedText;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: 9.h,
        ),
        decoration: BoxDecoration(
          color: selected
              ? palette.primary.withValues(alpha: enabled ? 0.10 : 0.045)
              : palette.primary.withValues(alpha: enabled ? 0.028 : 0.018),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected
                ? palette.primary.withValues(alpha: enabled ? 0.34 : 0.14)
                : palette.primary.withValues(alpha: enabled ? 0.10 : 0.06),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: !enabled
                      ? palette.mutedText
                      : selected
                      ? palette.primary
                      : palette.text,
                  fontSize: 10.6.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}