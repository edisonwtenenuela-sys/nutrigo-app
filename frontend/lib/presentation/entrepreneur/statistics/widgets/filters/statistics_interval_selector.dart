import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/stats/stats_model.dart';

class StatisticsIntervalSelector extends StatelessWidget {
  final SalesInterval selectedInterval;
  final ValueChanged<SalesInterval> onChanged;

  const StatisticsIntervalSelector({
    super.key,
    required this.selectedInterval,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.035),
            blurRadius: 12.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Row(
        children: [
          _IntervalChip(
            label: 'Diario',
            icon: Icons.calendar_view_day_rounded,
            selected: selectedInterval == SalesInterval.daily,
            onTap: () => onChanged(SalesInterval.daily),
          ),
          _IntervalChip(
            label: 'Semanal',
            icon: Icons.calendar_view_week_rounded,
            selected: selectedInterval == SalesInterval.weekly,
            onTap: () => onChanged(SalesInterval.weekly),
          ),
          _IntervalChip(
            label: 'Mensual',
            icon: Icons.calendar_month_rounded,
            selected: selectedInterval == SalesInterval.monthly,
            onTap: () => onChanged(SalesInterval.monthly),
          ),
        ],
      ),
    );
  }
}

class _IntervalChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _IntervalChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(vertical: 7.h),
          decoration: BoxDecoration(
            color: selected
                ? palette.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(13.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? palette.primary : palette.mutedText,
                size: 13.sp,
              ),
              SizedBox(width: 5.w),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? palette.primary : palette.mutedText,
                    fontSize: 10.3.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}