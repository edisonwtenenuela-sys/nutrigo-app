import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';

class RecommendationsPage extends StatelessWidget {
  const RecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final statsController = context.watch<StatsController>();
    final barGroups = RecommendationsScreenController.buildPeakHourBars(
      statsController,
    );

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        surfaceTintColor: palette.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Horarios de mayor venta',
          style: TextStyle(
            color: palette.text,
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: palette.primary,
        onRefresh: statsController.fetchStatistics,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          children: [
            Text(
              'Consulta las mejores horas para aplicar promociones.',
              style: TextStyle(
                color: palette.mutedText,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: palette.primary.withValues(alpha: 0.10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: palette.primary.withValues(alpha: 0.04),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: SizedBox(
                height: 300.h,
                child: barGroups.isEmpty
                    ? Center(
                  child: Text(
                    RecommendationsScreenController.emptyMessage(
                      statsController,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.secondary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
                    : BarChart(
                  BarChartData(
                    barGroups: barGroups,
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: palette.primary.withValues(alpha: 0.08),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: const FlTitlesData(
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}