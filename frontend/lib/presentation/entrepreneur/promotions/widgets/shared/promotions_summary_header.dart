import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/promotions/promotion_model.dart';

class PromotionsSummaryHeader extends StatelessWidget {
  final List<PromotionModel> promotions;

  const PromotionsSummaryHeader({super.key, required this.promotions});

  int get _activeCount => promotions
      .where((promotion) => promotion.status == PromotionStatus.active)
      .length;

  int get _scheduledCount => promotions
      .where((promotion) => promotion.status == PromotionStatus.scheduled)
      .length;

  int get _expiredCount => promotions
      .where((promotion) => promotion.status == PromotionStatus.expired)
      .length;

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: palette.primary.withValues(alpha: 0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: palette.primary.withValues(alpha: 0.06),
                  blurRadius: 14.r,
                  offset: Offset(0, 7.h),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(13.r),
                    border: Border.all(
                      color: palette.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Icon(
                    Icons.local_offer_rounded,
                    color: RoleTheme.iconColorFor(
                      Icons.local_offer_rounded,
                      fallback: palette.primary,
                    ),
                    size: 21.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Campañas comerciales',
                        maxLines: 2,
                        style: TextStyle(
                          color: palette.text,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        '${promotions.length} promociones registradas',
                        maxLines: 2,
                        style: TextStyle(
                          color: palette.mutedText,
                          fontSize: 10.7.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 9.h),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: palette.primary.withValues(alpha: 0.10),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _PromotionSummaryMetric(
                    value: _activeCount,
                    label: 'Activas',
                    color: RoleTheme.iconValidation,
                  ),
                ),
                const _MetricDivider(),
                Expanded(
                  child: _PromotionSummaryMetric(
                    value: _scheduledCount,
                    label: 'Programadas',
                    color: palette.primary,
                  ),
                ),
                const _MetricDivider(),
                Expanded(
                  child: _PromotionSummaryMetric(
                    value: _expiredCount,
                    label: 'Expiradas',
                    color: RoleTheme.iconDanger,
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

class _PromotionSummaryMetric extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _PromotionSummaryMetric({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final text = label.trim().isNotEmpty ? label.trim() : 'Estado';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          text,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 9.3.sp,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      width: 1,
      height: 28.h,
      color: palette.primary.withValues(alpha: 0.10),
    );
  }
}
