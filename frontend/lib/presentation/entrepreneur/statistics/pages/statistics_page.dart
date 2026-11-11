import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/stats/stats_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';
import 'package:emprendedor/presentation/entrepreneur/statistics/widgets/index.dart';
import 'package:emprendedor/presentation/shared/widgets/common/app_error_state.dart';

enum _StatisticsSection { summary, products, customers }

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  _StatisticsSection _selectedSection = _StatisticsSection.summary;

  Widget _gap([double height = 14]) => SizedBox(height: height.h);

  Future<void> _pickDateRange(
      BuildContext context,
      StatsController controller,
      ) async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange:
      controller.selectedDateRange ??
          StatisticsScreenController.defaultDateRange(),
      firstDate: StatisticsScreenController.firstSelectableDate(),
      lastDate: StatisticsScreenController.lastSelectableDate(),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      controller.setSelectedDateRange(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StatsController>();
    const palette = RoleTheme.entrepreneur;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: palette.primary,
          onRefresh: controller.fetchStatistics,
          child: _buildContent(context, controller, palette),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      StatsController controller,
      RolePalette palette,
      ) {
    final overview = controller.statisticsOverview;
    final uiState = StatisticsScreenController.resolveUiState(
      controller,
      overview,
    );

    if (uiState == StatisticsUiState.loading) {
      return _buildLoadingState(palette);
    }

    if (uiState == StatisticsUiState.error) {
      return _buildErrorState(controller.errorMessage!, controller);
    }

    if (uiState == StatisticsUiState.empty) {
      return _buildEmptyState(controller);
    }

    return _buildStatisticsContent(context, controller, overview!);
  }

  Widget _buildLoadingState(RolePalette palette) {
    return Center(child: CircularProgressIndicator(color: palette.primary));
  }

  Widget _buildErrorState(String message, StatsController controller) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 120.h),
        AppErrorState(message: message, onRetry: controller.fetchStatistics),
      ],
    );
  }

  Widget _buildEmptyState(StatsController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 96.h),
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 114.h,
              ),
              child: Center(
                child: StatisticsEmptyState(
                  onRefresh: controller.fetchStatistics,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatisticsContent(
      BuildContext context,
      StatsController controller,
      StatisticsOverview overview,
      ) {
    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 24.h),
      children: [
        StatisticsSummaryHeader(
          overview: overview,
          currentSalesData: controller.currentSalesData,
        ),
        _gap(12),
        StatisticsDateRangeCard(
          range: controller.selectedDateRange,
          onTap: () => _pickDateRange(context, controller),
        ),
        _gap(10),
        _StatisticsSectionSelector(
          selectedSection: _selectedSection,
          onChanged: (section) => setState(() => _selectedSection = section),
        ),
        _gap(),
        ..._buildSelectedSection(controller, overview),
        _gap(),
        StatisticsLastCalculatedBadge(
          lastCalculated: overview.lastCalculated.toDate(),
        ),
      ],
    );
  }

  List<Widget> _buildSelectedSection(
      StatsController controller,
      StatisticsOverview overview,
      ) {
    switch (_selectedSection) {
      case _StatisticsSection.summary:
        return _buildSummarySection(controller);
      case _StatisticsSection.products:
        return _buildProductsSection(overview);
      case _StatisticsSection.customers:
        return _buildCustomersSection(controller, overview);
    }
  }

  List<Widget> _buildSummarySection(StatsController controller) {
    return [
      StatisticsIntervalSelector(
        selectedInterval: controller.selectedSalesInterval,
        onChanged: controller.setSelectedSalesInterval,
      ),
      _gap(),
      const StatisticsSectionCard(
        icon: Icons.stacked_bar_chart_rounded,
        title: 'Ventas por periodo',
        subtitle: 'Analiza ingresos según el intervalo seleccionado.',
        child: SalesChartWidget(),
      ),
    ];
  }

  List<Widget> _buildProductsSection(StatisticsOverview overview) {
    return [
      TopItemsListWidget<TopProductStat>(
        title: 'Productos más vendidos',
        subtitle: 'Ordenados por cantidad e ingresos generados.',
        items: overview.topProducts,
        type: TopListType.products,
        itemBuilder: (context, product) {
          return TopProductTile(product: product);
        },
      ),
    ];
  }

  List<Widget> _buildCustomersSection(
      StatsController controller,
      StatisticsOverview overview,
      ) {
    return [
      TopItemsListWidget<FrequentCustomerStat>(
        title: 'Clientes frecuentes',
        subtitle: 'Usuarios con mayor recurrencia de compra.',
        items: overview.frequentCustomers,
        type: TopListType.customers,
        itemBuilder: (context, customer) {
          return FrequentCustomerTile(customer: customer);
        },
      ),
      _gap(),
      PeakHoursWidget(statsController: controller),
    ];
  }
}

class _StatisticsSectionSelector extends StatelessWidget {
  final _StatisticsSection selectedSection;
  final ValueChanged<_StatisticsSection> onChanged;

  const _StatisticsSectionSelector({
    required this.selectedSection,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.09),
        ),
      ),
      child: Row(
        children: [
          _SectionChip(
            label: 'Resumen',
            icon: Icons.dashboard_rounded,
            selected: selectedSection == _StatisticsSection.summary,
            onTap: () => onChanged(_StatisticsSection.summary),
          ),
          _SectionChip(
            label: 'Productos',
            icon: Icons.restaurant_menu_rounded,
            selected: selectedSection == _StatisticsSection.products,
            onTap: () => onChanged(_StatisticsSection.products),
          ),
          _SectionChip(
            label: 'Clientes',
            icon: Icons.groups_rounded,
            selected: selectedSection == _StatisticsSection.customers,
            onTap: () => onChanged(_StatisticsSection.customers),
          ),
        ],
      ),
    );
  }
}

class _SectionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SectionChip({
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
        borderRadius: BorderRadius.circular(13.r),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: selected ? palette.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(13.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? palette.surface : palette.primary,
                size: 13.5.sp,
              ),
              SizedBox(width: 5.w),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? palette.surface : palette.text,
                    fontSize: 10.5.sp,
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