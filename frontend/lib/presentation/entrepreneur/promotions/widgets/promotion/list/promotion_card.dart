import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/index.dart';

class PromotionCard extends StatelessWidget {
  final PromotionModel promotion;
  final VoidCallback onTap;

  const PromotionCard({
    super.key,
    required this.promotion,
    required this.onTap,
  });

  Color _statusColor(PromotionStatus status) {
    const palette = RoleTheme.entrepreneur;

    return switch (status) {
      PromotionStatus.active => palette.secondary,
      PromotionStatus.scheduled => palette.primary,
      PromotionStatus.expired => RoleTheme.iconDanger,
    };
  }

  String _statusLabel(PromotionStatus status) {
    return switch (status) {
      PromotionStatus.active => 'Activa',
      PromotionStatus.scheduled => 'Programada',
      PromotionStatus.expired => 'Expirada',
    };
  }

  String _discountText() {
    if (promotion.discountType == DiscountType.percentage) {
      return '${promotion.discountValue.toStringAsFixed(0)}% OFF';
    }

    return '${_moneyText(promotion.discountValue)} OFF';
  }

  String _moneyText(double value) {
    return NumberFormat.currency(
      locale: 'es_ES',
      symbol: r'$',
      decimalDigits: 2,
    ).format(value);
  }

  String _shortDateText(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'es_ES').format(date);
  }

  String _dateText() {
    final start = promotion.startDate.toDate();
    final end = promotion.endDate.toDate();

    if (promotion.status == PromotionStatus.expired) {
      return 'Finalizó el ${_shortDateText(end)}';
    }

    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return 'Hasta ${_shortDateText(end)}';
    }

    if (promotion.status == PromotionStatus.scheduled) {
      return 'Del ${_shortDateText(start)} al ${_shortDateText(end)}';
    }

    return 'Hasta ${_shortDateText(end)}';
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final color = _statusColor(promotion.status);
    final promotionName = promotion.name.trim().isNotEmpty
        ? promotion.name.trim()
        : 'Promoción';

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: palette.surface,
        borderRadius: BorderRadius.circular(17.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17.r),
              border: Border.all(color: color.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: palette.primary.withValues(alpha: 0.035),
                  blurRadius: 12.r,
                  offset: Offset(0, 6.h),
                ),
              ],
            ),
            child: Row(
              children: [
                _PromotionIcon(color: color, promotion: promotion),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PromotionStatusPill(
                        label: _statusLabel(promotion.status),
                        color: color,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        promotionName,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.text,
                          fontSize: 13.2.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _discountText(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Icon(
                            Icons.event_available_rounded,
                            color: RoleTheme.iconCalendar,
                            size: 11.sp,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              _dateText(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.mutedText,
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.chevron_right_rounded,
                  color: palette.mutedText.withValues(alpha: 0.7),
                  size: 22.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PromotionIcon extends StatelessWidget {
  final Color color;
  final PromotionModel promotion;

  const _PromotionIcon({required this.color, required this.promotion});

  @override
  Widget build(BuildContext context) {
    final icon = promotion.discountType == DiscountType.percentage
        ? Icons.percent_rounded
        : Icons.attach_money_rounded;

    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Icon(icon, color: color, size: 24.sp),
    );
  }
}

class _PromotionStatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _PromotionStatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final statusLabel = label.trim().isNotEmpty ? label.trim() : 'Estado';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4.5.w,
            height: 4.5.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 4.w),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: color,
                  fontSize: 8.8.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
