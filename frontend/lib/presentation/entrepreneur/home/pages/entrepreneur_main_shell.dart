import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/features/auth/controllers/auth_session_controller.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';
import 'package:emprendedor/presentation/auth/pages/auth_landing_page.dart';
import 'package:emprendedor/presentation/auth/widgets/common/auth_loading_screen.dart';
import 'package:emprendedor/presentation/entrepreneur/home/pages/entrepreneur_home_page.dart';
import 'package:emprendedor/presentation/entrepreneur/orders/pages/order_list_page.dart';
import 'package:emprendedor/presentation/entrepreneur/payments/pages/payment_methods_page.dart';
import 'package:emprendedor/presentation/entrepreneur/products/pages/product_list_page.dart';
import 'package:emprendedor/presentation/entrepreneur/profile/pages/index.dart';
import 'package:emprendedor/presentation/entrepreneur/promotions/pages/promotions_page.dart';
import 'package:emprendedor/presentation/entrepreneur/social/pages/social_media_page.dart';
import 'package:emprendedor/presentation/entrepreneur/statistics/pages/statistics_page.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';
import 'package:emprendedor/presentation/shared/widgets/common/logout_dialog.dart';

class EntrepreneurMainShell extends StatefulWidget {
  const EntrepreneurMainShell({super.key});

  @override
  State<EntrepreneurMainShell> createState() => _EntrepreneurMainShellState();
}

class _EntrepreneurMainShellState extends State<EntrepreneurMainShell> {
  final AuthSessionController _sessionController = AuthSessionController();

  final EntrepreneurMainShellController _shellController =
      EntrepreneurMainShellController();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      const EntrepreneurHomePage(),
      const ProductListPage(),
      const OrderListPage(),
      const StatisticsPage(),
      const PromotionsPage(),
      BusinessProfilePage(
        key: const ValueKey('business_profile_page'),
        onEditProfile: _goToEditProfile,
        onPaymentMethods: _goToPaymentMethods,
        onSocialMedia: _goToSocialMedia,
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _shellController.prepare(context.read<ProfileController>());
    });
  }

  @override
  void dispose() {
    _shellController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    if (!_shellController.startLogout()) return;

    final logoutFuture = _sessionController.logout(context);
    AppNavigator.replaceAll(context, const AuthLandingPage());

    await logoutFuture;
  }

  Future<void> _confirmLogout() async {
    final confirm = await showLogoutDialog(
      context,
      role: AppFeedbackRole.entrepreneur,
    );

    if (!mounted || !confirm) return;
    await _logout();
  }

  void _showVerificationPendingMessage() {
    showAppSnackMessage(
      context,
      role: AppFeedbackRole.entrepreneur,
      type: AppFeedbackType.warning,
      message: EntrepreneurMainShellController.pendingApprovalMessage,
    );
  }

  void _showEditProfileFeedback(BusinessProfileEditFeedback feedback) {
    showAppMessage(
      context,
      role: AppFeedbackRole.entrepreneur,
      type: switch (feedback.type) {
        BusinessProfileEditFeedbackType.success => AppFeedbackType.success,
        BusinessProfileEditFeedbackType.error => AppFeedbackType.error,
        BusinessProfileEditFeedbackType.warning => AppFeedbackType.warning,
        BusinessProfileEditFeedbackType.info => AppFeedbackType.info,
      },
      title: feedback.title,
      message: feedback.message,
    );
  }

  Future<void> _onItemTapped(int index) async {
    final selected = await _shellController.selectTab(index);

    if (!mounted) return;
    if (!selected) _showVerificationPendingMessage();
  }

  Future<void> _goToEditProfile() async {
    final userId = await _shellController.prepareEditProfile(
      context.read<ProfileController>(),
    );

    if (!mounted || userId == null) return;

    final feedback = await AppNavigator.push<BusinessProfileEditFeedback>(
      context,
      BusinessProfileEditPage(userId: userId),
    );

    if (!mounted || feedback == null) return;
    _showEditProfileFeedback(feedback);
  }

  Future<void> _goToPaymentMethods() async {
    final canOpen = await _shellController.preparePaymentMethods(
      context.read<PaymentMethodController>(),
    );

    if (!mounted || !canOpen) return;

    await AppNavigator.push(context, const PaymentMethodsPage());
  }

  Future<void> _goToSocialMedia() async {
    final canOpen = await _shellController.prepareSocialMedia(
      context.read<SocialMediaController>(),
    );

    if (!mounted || !canOpen) return;

    await AppNavigator.push(context, const SocialMediaPage());
  }

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        icon: const Icon(Icons.logout),
        tooltip: 'Cerrar sesión',
        onPressed: _confirmLogout,
      ),
    ];
  }

  AppBar _buildAppBar(RolePalette palette) {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      backgroundColor: palette.surface,
      surfaceTintColor: palette.surface,
      title: Text(
        _shellController.currentTitle,
        style: TextStyle(
          fontSize: 19.sp,
          fontWeight: FontWeight.w900,
          color: palette.text,
        ),
      ),
      actions: _buildAppBarActions(),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(RolePalette palette) {
    return BottomNavigationBar(
      currentIndex: _shellController.selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: palette.primary,
      unselectedItemColor: palette.mutedText,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 10.sp,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 9.sp,
      ),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Productos'),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Pedidos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Estadísticas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_offer),
          label: 'Promociones',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return ListenableBuilder(
      listenable: _shellController,
      builder: (context, _) {
        if (_shellController.isPreparingShell) return const AuthLoadingScreen();
        return Scaffold(
          backgroundColor: palette.background,
          appBar: _buildAppBar(palette),
          body: IndexedStack(
            index: _shellController.selectedIndex,
            children: _pages,
          ),
          bottomNavigationBar: _buildBottomNavigationBar(palette),
        );
      },
    );
  }
}
