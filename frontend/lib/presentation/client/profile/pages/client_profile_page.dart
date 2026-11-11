import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/auth/controllers/auth_session_controller.dart';
import 'package:emprendedor/features/client/controllers/client_profile_controller.dart';
import 'package:emprendedor/features/client/controllers/client_profile_view_controller.dart';
import 'package:emprendedor/presentation/auth/pages/auth_landing_page.dart';
import 'package:emprendedor/presentation/client/profile/pages/client_profile_edit_page.dart';
import 'package:emprendedor/presentation/client/profile/widgets/index.dart';
import 'package:emprendedor/presentation/shared/widgets/buttons/app_action_button.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';
import 'package:emprendedor/presentation/shared/widgets/common/logout_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({super.key});

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  final AuthSessionController _sessionController = AuthSessionController();
  late final ClientProfileViewController _viewController;

  Route<void> _landingRoute() {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const AuthLandingPage(),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  Widget _vGap(double value) => SizedBox(height: value.h);

  @override
  void initState() {
    super.initState();
    _viewController = ClientProfileViewController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _viewController.ensureProfileLoaded(
        context.read<ClientProfileController>(),
      );
    });
  }

  @override
  void dispose() {
    _viewController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirm = await showLogoutDialog(
      context,
      role: AppFeedbackRole.client,
    );

    if (!confirm || !mounted) return;

    final logoutFuture = _sessionController.logout(context);
    AppNavigator.replaceAllRoute(context, _landingRoute(), rootNavigator: true);

    await logoutFuture;
  }

  Future<void> _openEditProfile(ClientProfileController controller) async {
    controller.clearError();
    final snapshot = _viewController.captureEditSnapshot(controller);

    final saved = await AppNavigator.push<bool>(
      context,
      const ClientProfileEditPage(),
    );

    if (!mounted) return;

    if (saved != true) {
      _viewController.restoreAfterCancelledEdit(
        controller: controller,
        snapshot: snapshot,
      );
    }

    controller.clearError();
  }

  AppBar _buildAppBar(RolePalette palette) {
    return AppBar(
      backgroundColor: palette.background,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: palette.text),
      title: Text(
        'Mi perfil',
        style: TextStyle(
          color: palette.text,
          fontWeight: FontWeight.w900,
          fontSize: 19.sp,
        ),
      ),
    );
  }

  Widget _buildProfileContent({
    required ClientProfileController controller,
    required UserSessionSnapshot? session,
    required RolePalette palette,
  }) {
    final headerVerified = _viewController.resolveHeaderVerified(
      controller,
      session,
    );

    final shouldShowEmailVerificationCard = _viewController
        .shouldShowEmailVerificationCard(
          session: session,
          controller: controller,
        );

    return RefreshIndicator(
      color: RoleTheme.iconProfile,
      onRefresh: controller.loadProfile,
      child: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
        children: [
          ClientProfileHeaderCard(
            name: controller.nameController.text,
            goal: controller.goalController.text,
            imageUrl: controller.profileImageUrl,
            isVerified: headerVerified,
            isUploadingImage: controller.isUploadingImage,
            onChangePhoto: controller.pickAndUploadProfileImage,
          ),
          _vGap(14),
          ClientProfileAccountSection(
            controller: controller,
            session: session,
            shouldShowEmailVerificationCard: shouldShowEmailVerificationCard,
            onVerificationChanged: _viewController.refreshView,
          ),
          _vGap(12),
          ClientProfilePersonalDataSection(controller: controller),
          _vGap(12),
          ClientProfileDeliverySection(controller: controller),
          if (_viewController.hasHealthData(controller)) ...[
            _vGap(12),
            ClientProfileHealthSection(controller: controller),
          ],
          if (controller.errorMessage != null)
            ClientProfileErrorInlineCard(message: controller.errorMessage!),
          _vGap(18),
          ClientActionButton(
            label: 'Editar perfil',
            icon: Icons.edit_rounded,
            onPressed: () => _openEditProfile(controller),
          ),
          _vGap(10),
          ProfileLogoutButton(onPressed: _logout),
        ],
      ),
    );
  }

  Widget _buildPageBody({
    required ClientProfileController controller,
    required UserSessionSnapshot? session,
    required RolePalette palette,
  }) {
    final uiState = _viewController.resolveUiState(controller);

    return SafeArea(
      child: switch (uiState) {
        ClientProfileUiState.loading => const ClientProfileLoadingView(),
        ClientProfileUiState.content => _buildProfileContent(
          controller: controller,
          session: session,
          palette: palette,
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ClientProfileController>();
    const palette = RoleTheme.client;

    return ListenableBuilder(
      listenable: _viewController,
      builder: (context, _) {
        final session = _viewController.currentSession;

        return Scaffold(
          backgroundColor: palette.background,
          resizeToAvoidBottomInset: true,
          appBar: _buildAppBar(palette),
          body: _buildPageBody(
            controller: controller,
            session: session,
            palette: palette,
          ),
        );
      },
    );
  }
}
