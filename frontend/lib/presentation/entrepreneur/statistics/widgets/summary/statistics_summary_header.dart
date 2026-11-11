import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/stats/stats_model.dart';

class StatisticsSummaryHeader extends StatelessWidget {
  final StatisticsOverview overview;
  final List<SalesDataPoint> currentSalesData;

  const StatisticsSummaryHeader({
    super.key,
    required this.overview,
    required this.currentSalesData,
  });

  double get _totalSales {
    return currentSalesData.fold<double>(
      0,
      (value, item) => value + item.salesAmount,
    );
  }

  int get _totalOrders {
    return currentSalesData.fold<int>(
      0,
      (value, item) => value + item.orderCount,
    );
  }

  double get _averageTicket {
    if (_totalOrders == 0) return 0;
    return _totalSales / _totalOrders;
  }

  String _money(double value) => '\$${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 11.h, 14.w, 10.h),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(21.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.07),
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: palette.primary.withValues(alpha: 0.12),
                  ),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: RoleTheme.iconColorFor(
                    Icons.analytics_rounded,
                    fallback: palette.primary,
                  ),
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Panel de estadísticas',
                      maxLines: 2,
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 14.4.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Indicadores clave de tu negocio.',
                      maxLines: 2,
                      style: TextStyle(
                        color: palette.mutedText,
                        fontSize: 10.2.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 92.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _money(_totalSales),
                        maxLines: 1,
                        style: TextStyle(
                          color: palette.primary,
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Ventas del periodo',
                      maxLines: 2,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: palette.mutedText,
                        fontSize: 8.6.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.08,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(13.r),
              border: Border.all(
                color: palette.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _InlineMetric(
                    label: 'Pedidos',
                    value: '$_totalOrders',
                  ),
                ),
                const _MetricDivider(),
                Expanded(
                  child: _InlineMetric(
                    label: 'Ticket prom.',
                    value: _money(_averageTicket),
                  ),
                ),
                const _MetricDivider(),
                Expanded(
                  child: _InlineMetric(
                    label: 'Clientes',
                    value: '${overview.frequentCustomers.length}',
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

class _InlineMetric extends StatelessWidget {
  final String label;
  final String value;

  const _InlineMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.primary,
            fontSize: 10.8.sp,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          label,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: palette.mutedText,
            fontSize: 8.1.sp,
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
      height: 22.h,
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      color: palette.primary.withValues(alpha: 0.12),
    );
  }
}
