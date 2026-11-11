import 'package:flutter/material.dart';

import 'package:emprendedor/data/models/entrepreneur/stats/stats_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/stats_controller.dart';

enum StatisticsUiState { loading, error, empty, ready }

class StatisticsScreenController {
  const StatisticsScreenController._();

  static StatisticsUiState resolveUiState(
    StatsController controller,
    StatisticsOverview? overview,
  ) {
    if (controller.isLoading && overview == null) {
      return StatisticsUiState.loading;
    }

    if (controller.errorMessage != null && overview == null) {
      return StatisticsUiState.error;
    }

    if (overview == null || !hasStatisticsData(overview, controller)) {
      return StatisticsUiState.empty;
    }

    return StatisticsUiState.ready;
  }

  static DateTimeRange defaultDateRange({DateTime? now}) {
    final referenceDate = now ?? DateTime.now();
    return DateTimeRange(
      start: referenceDate.subtract(const Duration(days: 30)),
      end: referenceDate,
    );
  }

  static DateTime firstSelectableDate() => DateTime(2020);

  static DateTime lastSelectableDate({DateTime? now}) {
    return (now ?? DateTime.now()).add(const Duration(days: 1));
  }

  static bool hasStatisticsData(
    StatisticsOverview overview,
    StatsController controller,
  ) {
    final hasSales = [
      ...overview.dailySales,
      ...overview.weeklySales,
      ...overview.monthlySales,
    ].any((item) => item.salesAmount > 0 || item.orderCount > 0);

    return hasSales ||
        overview.topProducts.isNotEmpty ||
        overview.frequentCustomers.isNotEmpty ||
        controller.peakSalesHours.isNotEmpty;
  }
}








