import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/auth/controllers/auth_session_controller.dart';
import 'package:emprendedor/features/nutritionist/controllers/index.dart';
import 'package:emprendedor/presentation/auth/pages/auth_landing_page.dart';
import 'package:emprendedor/presentation/auth/widgets/common/auth_loading_screen.dart';
import 'package:emprendedor/presentation/nutritionist/appointments/pages/nutritionist_appointments_page.dart';
import 'package:emprendedor/presentation/nutritionist/home/pages/nutritionist_home_page.dart';
import 'package:emprendedor/presentation/nutritionist/patients/pages/nutritionist_patients_page.dart';
import 'package:emprendedor/presentation/nutritionist/products/pages/nutritionist_products_validation_page.dart';
import 'package:emprendedor/presentation/nutritionist/profile/pages/nutritionist_profile_page.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';
import 'package:emprendedor/presentation/shared/widgets/common/logout_dialog.dart';

class NutritionistMainShell extends StatefulWidget {
  const NutritionistMainShell({super.key});

  @override
  State<NutritionistMainShell> createState() => _NutritionistMainShellState();
}

class _NutritionistMainShellState extends State<NutritionistMainShell> {
  final AuthSessionController _sessionController = AuthSessionController();
  final NutritionistMainShellController _shellController =
      NutritionistMainShellController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await _shellController.prepare(
        context.read<NutritionistProfileController>(),
      );
    });
  }

  @override
  void dispose() {
    _shellController.dispose();
    super.dispose();
  }

  void _showPendingMessage() {
    showAppSnackMessage(
      context,
      role: AppFeedbackRole.nutritionist,
      type: AppFeedbackType.warning,
      message: NutritionistMainShellController.pendingApprovalMessage,
    );
  }

  Future<void> _logout() async {
    final confirm = await showLogoutDialog(
      context,
      role: AppFeedbackRole.nutritionist,
    );

    if (!mounted || !confirm) return;

    final logoutFuture = _sessionController.logout(context);
    AppNavigator.replaceAll(context, const AuthLandingPage());

    await logoutFuture;
  }

  void _onTabSelected(int index, bool isVerified) {
    final selected = _shellController.selectTab(
      index: index,
      isVerified: isVerified,
    );

    if (!selected) _showPendingMessage();
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
      actions: [
        IconButton(
          tooltip: 'Cerrar sesión',
          onPressed: _logout,
          icon: Icon(
            Icons.logout_rounded,
            color: RoleTheme.iconColorFor(
              Icons.logout_rounded,
              fallback: palette.primary,
            ),
            size: 24.sp,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPages(bool isVerified) {
    return [
      NutritionistHomePage(isVerified: isVerified),
      isVerified
          ? const NutritionistAppointmentsPage()
          : const SizedBox.shrink(),
      isVerified ? const NutritionistPatientsPage() : const SizedBox.shrink(),
      isVerified
          ? const NutritionistProductsValidationPage()
          : const SizedBox.shrink(),
      const NutritionistProfilePage(),
    ];
  }

  BottomNavigationBar _buildBottomNavigationBar(
    RolePalette palette,
    bool isVerified,
  ) {
    return BottomNavigationBar(
      currentIndex: _shellController.selectedIndex,
      onTap: (index) => _onTabSelected(index, isVerified),
      type: BottomNavigationBarType.fixed,
      backgroundColor: palette.surface,
      selectedItemColor: palette.primary,
      unselectedItemColor: palette.mutedText,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 10.sp,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 9.sp,
      ),
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home_rounded,
            color: RoleTheme.iconColorFor(
              Icons.home_rounded,
              fallback: palette.primary,
            ),
          ),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.calendar_today_rounded,
            color: RoleTheme.iconColorFor(
              Icons.calendar_today_rounded,
              fallback: palette.primary,
            ),
          ),
          label: 'Citas',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.people_rounded,
            color: RoleTheme.iconColorFor(
              Icons.people_rounded,
              fallback: palette.primary,
            ),
          ),
          label: 'Pacientes',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.verified_rounded,
            color: RoleTheme.iconColorFor(
              Icons.verified_rounded,
              fallback: palette.primary,
            ),
          ),
          label: 'Validar',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person_rounded,
            color: RoleTheme.iconColorFor(
              Icons.person_rounded,
              fallback: palette.primary,
            ),
          ),
          label: 'Perfil',
        ),
      ],
    );
  }

  Widget _buildVerifiedShell(String userId, RolePalette palette) {
    final initialVerified = context
        .watch<NutritionistProfileController>()
        .isVerified;

    return StreamBuilder<bool>(
      stream: _shellController.watchVerified(userId),
      initialData: initialVerified,
      builder: (context, snapshot) {
        final isVerified = snapshot.data ?? false;
        final pages = _buildPages(isVerified);

        return Scaffold(
          backgroundColor: palette.background,
          appBar: _buildAppBar(palette),
          body: pages[_shellController.selectedIndex],
          bottomNavigationBar: _buildBottomNavigationBar(palette, isVerified),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return ListenableBuilder(
      listenable: _shellController,
      builder: (context, _) {
        final userId = _shellController.currentUserId;

        if (userId == null) return const SizedBox.shrink();

        if (_shellController.isPreparingShell) {
          return const AuthLoadingScreen();
        }

        return _buildVerifiedShell(userId, palette);
      },
    );
  }
}
