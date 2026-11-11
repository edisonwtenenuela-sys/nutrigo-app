import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistPatientsOverviewCard extends StatelessWidget {
  final int total;
  final int active;
  final int completed;

  const NutritionistPatientsOverviewCard({
    super.key,
    required this.total,
    required this.active,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    final metrics = [
      (value: total.toString(), label: 'Total'),
      (value: active.toString(), label: 'Activos'),
      (value: completed.toString(), label: 'Atendidos'),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(17.w),
      decoration: BoxDecoration(
        gradient: palette.headerGradient,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 22.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: palette.surface.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Icon(
                  Icons.groups_rounded,
                  color: RoleTheme.iconColorFor(
                    Icons.groups_rounded,
                    fallback: palette.primary,
                  ),
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seguimiento de pacientes',
                      style: TextStyle(
                        color: palette.surface,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Consulta el historial básico de quienes ya atiendes.',
                      style: TextStyle(
                        color: palette.surface.withValues(alpha: 0.84),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              for (var i = 0; i < metrics.length; i++) ...[
                Expanded(
                  child: _OverviewMetric(
                    value: metrics[i].value,
                    label: metrics[i].label,
                  ),
                ),
                if (i < metrics.length - 1) SizedBox(width: 9.w),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  final String value;
  final String label;

  const _OverviewMetric({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: palette.text,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}