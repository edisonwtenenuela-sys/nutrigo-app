import 'package:fl_chart/fl_chart.dart';

import 'package:emprendedor/features/entrepreneur/controllers/stats_controller.dart';

class RecommendationsScreenController {
  const RecommendationsScreenController._();

  static List<BarChartGroupData> buildPeakHourBars(StatsController controller) {
    final entries = controller.peakSalesHours.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [BarChartRodData(toY: entry.value.toDouble())],
      );
    }).toList();
  }

  static String emptyMessage(StatsController controller) {
    if (controller.isLoading) return 'Calculando horarios recomendados...';
    return 'Aun no hay ventas suficientes para recomendar horarios.';
  }
}








