import 'package:flutter/material.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/features/client/controllers/index.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/auth/pages/auth_landing_page.dart';
import 'package:emprendedor/presentation/auth/widgets/common/auth_loading_screen.dart';
import 'package:emprendedor/presentation/client/appointments/pages/schedule_appointment_page.dart';
import 'package:emprendedor/presentation/client/home/widgets/client_health_card.dart';
import 'package:emprendedor/presentation/client/home/widgets/client_home_header.dart';
import 'package:emprendedor/presentation/client/home/widgets/client_option_card.dart';
import 'package:emprendedor/presentation/client/home/widgets/quick_summary_section.dart';
import 'package:emprendedor/presentation/client/orders/pages/index.dart';
import 'package:emprendedor/presentation/client/products/pages/index.dart';
import 'package:emprendedor/presentation/client/profile/pages/client_profile_page.dart';
import 'package:emprendedor/features/auth/controllers/auth_session_controller.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';
import 'package:emprendedor/presentation/shared/widgets/common/logout_dialog.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  final AuthSessionController _sessionController = AuthSessionController();
  final ClientProductsController _productsPreloader =
      ClientProductsController();
  final ClientOrderBusinessController _orderBusinessPreloader =
      ClientOrderBusinessController();

  Route<void> _landingRoute() {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const AuthLandingPage(),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _refreshHomeData();
    });
  }

  Future<void> _refreshHomeData() async {
    final userId = _sessionController.currentUserId();
    if (userId == null || !mounted) return;

    await Future.wait([
      context.read<ClientProfileController>().loadProfile(),
      _preloadOrders(userId),
      context.read<AppointmentController>().loadNutritionists(),
      context.read<AppointmentController>().watchAppointmentsCount(),
      context.read<CartController>().watchCart(),
      _productsPreloader.preloadApprovedProducts(),
    ]);
  }

  Future<void> _preloadOrders(String userId) async {
    final orderController = context.read<ClientOrderController>();
    await orderController.setUserId(userId);
    await _orderBusinessPreloader.preloadBusinessSummaries(
      orderController.orders,
    );
  }

  @override
  void dispose() {
    _productsPreloader.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showLogoutDialog(
      context,
      role: AppFeedbackRole.client,
    );

    if (!context.mounted || !confirm) return;

    final logoutFuture = _sessionController.logout(context);
    AppNavigator.replaceAllRoute(context, _landingRoute(), rootNavigator: true);

    await logoutFuture;
  }

  String _formatClientName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return 'Cliente';
    }

    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'Cliente';
    if (parts.length == 1) return parts[0];

    return '${parts[0]} ${parts[1]}';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';

    return 'Buenas noches';
  }

  void _pushPage(Widget page) {
    AppNavigator.push(context, page);
  }

  AppBar _buildAppBar(RolePalette palette) {
    return AppBar(
      backgroundColor: palette.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Inicio',
        style: TextStyle(
          color: palette.text,
          fontWeight: FontWeight.w900,
          fontSize: 19.sp,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _logout(context),
          icon: Icon(
            Icons.logout,
            size: 24.sp,
            color: RoleTheme.iconColorFor(
              Icons.logout,
              fallback: RoleTheme.iconInfo,
            ),
          ),
          tooltip: 'Cerrar sesión',
        ),
      ],
    );
  }

  Widget _buildQuickAccessSection(RolePalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accesos rápidos',
          style: TextStyle(
            color: palette.text,
            fontSize: 17.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 8.h),
        ..._buildQuickOptions(),
      ],
    );
  }

  List<Widget> _buildQuickOptions() {
    final options =
        <
          ({
            IconData icon,
            Color color,
            String title,
            String subtitle,
            VoidCallback onTap,
          })
        >[
          (
            icon: Icons.restaurant_menu_rounded,
            color: RoleTheme.iconHealth,
            title: 'Comidas saludables',
            subtitle: 'Explora opciones disponibles para ti',
            onTap: () => _pushPage(const ClientProductsPage()),
          ),
          (
            icon: Icons.shopping_cart_rounded,
            color: RoleTheme.iconOrders,
            title: 'Mis pedidos',
            subtitle: 'Consulta tus compras realizadas',
            onTap: () => _pushPage(const ClientOrdersPage()),
          ),
          (
            icon: Icons.calendar_month_rounded,
            color: RoleTheme.iconCalendar,
            title: 'Agendar cita',
            subtitle: 'Reserva una cita con un nutricionista',
            onTap: () => _pushPage(const ScheduleAppointmentPage()),
          ),
          (
            icon: Icons.person_rounded,
            color: RoleTheme.iconProfile,
            title: 'Perfil',
            subtitle: 'Revisa y actualiza tu información',
            onTap: () => _pushPage(const ClientProfilePage()),
          ),
        ];

    return options
        .map(
          (item) => ClientOptionCard(
            icon: item.icon,
            iconColor: item.color,
            title: item.title,
            subtitle: item.subtitle,
            onTap: item.onTap,
          ),
        )
        .toList();
  }

  Widget _buildPageBody({
    required RolePalette palette,
    required String displayName,
    required ClientProfileController profileController,
  }) {
    return SafeArea(
      child: RefreshIndicator(
        color: RoleTheme.iconInfo,
        onRefresh: _refreshHomeData,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 34.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClientHomeHeader(
                displayName: displayName,
                imageUrl: profileController.profileImageUrl,
                greeting: _getGreeting(),
              ),
              SizedBox(height: 12.h),
              const ClientHealthCard(),
              SizedBox(height: 14.h),
              _buildQuickAccessSection(palette),
              SizedBox(height: 6.h),
              const QuickSummarySection(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ClientProfileController>();
    const palette = RoleTheme.client;

    final displayName = _formatClientName(profileController.profile?.name);

    if (profileController.profile == null) {
      return const AuthLoadingScreen();
    }

    return Scaffold(
      backgroundColor: palette.background,
      appBar: _buildAppBar(palette),
      body: _buildPageBody(
        palette: palette,
        displayName: displayName,
        profileController: profileController,
      ),
    );
  }
}
