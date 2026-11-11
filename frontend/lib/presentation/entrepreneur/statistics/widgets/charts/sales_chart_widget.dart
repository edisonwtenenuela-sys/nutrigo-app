import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/stats/stats_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/stats_controller.dart';

class SalesChartWidget extends StatelessWidget {
  const SalesChartWidget({super.key});

  static const Color _salesStartColor = Color(0xFF16A34A);
  static const Color _salesMiddleColor = Color(0xFF22C55E);
  static const Color _salesEndColor = Color(0xFFF59E0B);
  static const Color _salesSoftColor = Color(0xFFEAFBF1);
  static const Color _salesGridColor = Color(0xFFD8F3E0);

  @override
  Widget build(BuildContext context) {
    final statsController = context.watch<StatsController>();
    final salesData = statsController.currentSalesData;
    final interval = statsController.selectedSalesInterval;

    const palette = RoleTheme.entrepreneur;

    if (salesData.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: palette.primary.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: RoleTheme.iconColorFor(
                Icons.info_outline_rounded,
                fallback: palette.primary,
              ),
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'No hay datos de ventas para este intervalo.',
                style: TextStyle(
                  color: palette.text,
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final maxY = _calculateMaxY(salesData);

    return SizedBox(
      height: 184.h,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: _salesGridColor, strokeWidth: 1);
            },
          ),
          borderData: FlBorderData(show: false),
          barTouchData: _buildTooltip(salesData, interval),
          titlesData: _buildTitles(salesData, interval, maxY),
          barGroups: _buildBars(salesData, interval),
        ),
      ),
    );
  }

  double _calculateMaxY(List<SalesDataPoint> data) {
    if (data.isEmpty) return 100;

    final maxValue = data
        .map((item) => item.salesAmount)
        .reduce((a, b) => a > b ? a : b);

    if (maxValue <= 0) return 100;

    return maxValue * 1.25;
  }

  BarTouchData _buildTooltip(
    List<SalesDataPoint> salesData,
    SalesInterval interval,
  ) {
    const palette = RoleTheme.entrepreneur;

    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) {
          return palette.text.withValues(alpha: 0.95);
        },
        tooltipPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final data = salesData[groupIndex];
          final title = _formatDate(data.date, interval);

          return BarTooltipItem(
            '$title\n',
            TextStyle(
              color: palette.surface,
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
            ),
            children: [
              TextSpan(
                text: NumberFormat.currency(
                  locale: 'es_ES',
                  symbol: '\$',
                  decimalDigits: 2,
                ).format(data.salesAmount),
                style: TextStyle(
                  color: palette.accent,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: '\n${data.orderCount} pedidos',
                style: TextStyle(
                  color: palette.surface.withValues(alpha: 0.82),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  FlTitlesData _buildTitles(
    List<SalesDataPoint> salesData,
    SalesInterval interval,
    double maxY,
  ) {
    const palette = RoleTheme.entrepreneur;

    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24.h,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();

            if (index < 0 || index >= salesData.length) {
              return const SizedBox.shrink();
            }

            final data = salesData[index];

            return SideTitleWidget(
              meta: meta,
              child: Padding(
                padding: EdgeInsets.only(top: 3.h),
                child: Text(
                  _formatShortDate(data.date, interval),
                  style: TextStyle(
                    color: palette.text.withValues(alpha: 0.70),
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 42.w,
          interval: maxY / 4,
          getTitlesWidget: (value, meta) {
            return SideTitleWidget(
              meta: meta,
              child: Text(
                value == 0
                    ? '\$0'
                    : NumberFormat.compactCurrency(
                        locale: 'es_ES',
                        symbol: '\$',
                      ).format(value),
                style: TextStyle(
                  color: palette.text.withValues(alpha: 0.62),
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  List<BarChartGroupData> _buildBars(
    List<SalesDataPoint> salesData,
    SalesInterval interval,
  ) {
    final maxY = _calculateMaxY(salesData);

    return salesData.asMap().entries.map((entry) {
      final intensity = (entry.value.salesAmount / maxY).clamp(0.0, 1.0);
      final topColor = Color.lerp(
        _salesMiddleColor,
        _salesEndColor,
        intensity * 0.65,
      )!;

      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.salesAmount,
            gradient: LinearGradient(
              colors: [_salesStartColor, topColor],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: interval == SalesInterval.daily ? 14.w : 18.w,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxY,
              color: _salesSoftColor,
            ),
          ),
        ],
      );
    }).toList();
  }

  String _formatDate(DateTime date, SalesInterval interval) {
    switch (interval) {
      case SalesInterval.daily:
        return DateFormat('d MMM', 'es_ES').format(date);

      case SalesInterval.weekly:
        return DateFormat('d MMM yy', 'es_ES').format(date);

      case SalesInterval.monthly:
        return DateFormat('MMM yyyy', 'es_ES').format(date);
    }
  }

  String _formatShortDate(DateTime date, SalesInterval interval) {
    switch (interval) {
      case SalesInterval.daily:
        return DateFormat('d', 'es_ES').format(date);

      case SalesInterval.weekly:
        return 'S${_weekOfYear(date)}';

      case SalesInterval.monthly:
        return DateFormat('MMM', 'es_ES').format(date).substring(0, 3);
    }
  }

  int _weekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year);
    final daysOffset = firstDayOfYear.weekday - DateTime.monday;
    final firstMonday = firstDayOfYear.subtract(Duration(days: daysOffset));
    final difference = date.difference(firstMonday).inDays;

    return (difference / 7).floor() + 1;
  }
}
