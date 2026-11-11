import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';
import 'package:emprendedor/presentation/entrepreneur/home/widgets/index.dart';

class EntrepreneurHomePage extends StatefulWidget {
  const EntrepreneurHomePage({super.key});

  @override
  State<EntrepreneurHomePage> createState() => _EntrepreneurHomePageState();
}

class _EntrepreneurHomePageState extends State<EntrepreneurHomePage> {
  final EntrepreneurHomeController _screenController =
      EntrepreneurHomeController();
  final BusinessStatusController _statusController = BusinessStatusController();

  bool _initialized = false;
  Map<String, dynamic>? _initialVerificationData;

  @override
  void initState() {
    super.initState();
    _initialVerificationData = _statusController.cachedVerificationData();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _initialized) return;

      _initialized = true;
      await _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    Map<String, dynamic>? verificationData;

    try {
      final results = await Future.wait<Object?>([
        _screenController.loadDashboardData(
          profileController: context.read<ProfileController>(),
          orderController: context.read<OrderController>(),
          statsController: context.read<StatsController>(),
        ),
        _statusController.loadVerificationData(),
      ]);
      verificationData = results[1] as Map<String, dynamic>?;
    } catch (_) {}

    if (!mounted) return;

    setState(() => _initialVerificationData = verificationData);
  }

  Future<void> _refreshDashboard() async {
    if (!mounted) return;

    Map<String, dynamic>? verificationData;

    try {
      final results = await Future.wait<Object?>([
        _screenController.refreshDashboard(
          profileController: context.read<ProfileController>(),
          orderController: context.read<OrderController>(),
          statsController: context.read<StatsController>(),
        ),
        _statusController.loadVerificationData(),
      ]);
      verificationData = results[1] as Map<String, dynamic>?;
    } catch (_) {}

    if (!mounted || verificationData == null) return;

    setState(() {
      _initialVerificationData = verificationData;
    });
  }

  bool _isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 600;
  }

  Widget _buildDashboardBody({
    required bool isTablet,
    required RolePalette palette,
    required ProfileController profileController,
    required OrderController orderController,
    required EntrepreneurDashboardViewData viewData,
  }) {
    final dateFormatter = _screenController.dateFormatter;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 21 : 15.w,
          vertical: isTablet ? 13 : 8.h,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 850 : double.infinity,
            ),
            child: Column(
              children: [
                WelcomeHeader(
                  greetingText: viewData.greetingText,
                  imageUrl: profileController.businessProfile?.profileImageUrl,
                  activeOrders: orderController.activeOrders,
                  monthIncome: _screenController.formatCurrency(
                    viewData.monthIncome,
                  ),
                ),
                SizedBox(height: isTablet ? 18 : 15.h),
                const DashboardSectionTitle(
                  title: 'Resumen del negocio',
                  subtitle: 'Indicadores principales de tu actividad.',
                ),
                SizedBox(height: isTablet ? 12 : 10.h),
                QuickStatsGrid(
                  children: [
                    InfoCard(
                      title: 'Ventas',
                      value: _screenController.formatCurrency(
                        viewData.totalSalesAmount,
                      ),
                      caption: viewData.latestSaleDate != null
                          ? 'Último: ${dateFormatter.format(viewData.latestSaleDate!)}'
                          : 'Sin ventas registradas',
                      icon: Icons.attach_money_rounded,
                      valueColor: palette.primary,
                    ),
                    InfoCard(
                      title: 'Pedidos hoy',
                      value: '${viewData.todayOrders}',
                      caption: 'Entregados hoy',
                      icon: Icons.today_rounded,
                      valueColor: palette.secondary,
                    ),
                    InfoCard(
                      title: 'Pedidos pagados',
                      value: '${orderController.paidOrders}',
                      caption: 'Entregados y pagados',
                      icon: Icons.verified_rounded,
                      valueColor: palette.accent,
                    ),
                    InfoCard(
                      title: 'Clientes frecuentes',
                      value:
                          '${viewData.statisticsOverview.frequentCustomers.length}',
                      caption: 'Compradores recurrentes',
                      icon: Icons.groups_rounded,
                      valueColor: palette.secondary,
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 16 : 14.h),
                const DashboardSectionTitle(
                  title: 'Operación del negocio',
                  subtitle: 'Verificación, seguridad y validación.',
                ),
                SizedBox(height: isTablet ? 12 : 10.h),
                BusinessStatusCard(
                  initialVerificationData: _initialVerificationData,
                ),
                SizedBox(height: isTablet ? 16 : 14.h),
                const DashboardTipCard(
                  message:
                      'Revisa tus pedidos y productos para mantener tu negocio actualizado y mejorar la experiencia de tus clientes.',
                ),
                if (viewData.dashboardError != null) ...[
                  SizedBox(height: isTablet ? 12 : 8.h),
                  ErrorCard(message: viewData.dashboardError!),
                ],
                SizedBox(height: isTablet ? 22 : 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    const palette = RoleTheme.entrepreneur;

    return Consumer3<ProfileController, OrderController, StatsController>(
      builder:
          (
            context,
            profileController,
            orderController,
            statsController,
            child,
          ) {
            final viewData = _screenController.buildViewData(
              profileController: profileController,
              orderController: orderController,
              statsController: statsController,
            );

            return RefreshIndicator(
              color: palette.primary,
              onRefresh: _refreshDashboard,
              child: _buildDashboardBody(
                isTablet: isTablet,
                palette: palette,
                profileController: profileController,
                orderController: orderController,
                viewData: viewData,
              ),
            );
          },
    );
  }
}
