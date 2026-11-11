import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/admin/controllers/admin_history_controller.dart';
import 'package:emprendedor/features/admin/controllers/admin_home_controller.dart';
import 'package:emprendedor/presentation/admin/pages/admin_verification_page.dart';
import 'package:emprendedor/presentation/admin/pages/admin_verification_history_page.dart';
import 'package:emprendedor/presentation/admin/pages/nutritionist_verification_page.dart';
import 'package:emprendedor/presentation/admin/widgets/index.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final AdminHomeController _controller = AdminHomeController();

  Widget _vGap(double value) => SizedBox(height: value.h);

  @override
  void initState() {
    super.initState();
    _controller.startPendingRequestWatcher(onNotice: _showPendingNotice);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 600;
  }

  void _goToEntrepreneurVerification(BuildContext context) {
    AppNavigator.push(context, const AdminVerificationPage());
  }

  void _goToNutritionistVerification(BuildContext context) {
    AppNavigator.push(context, const NutritionistVerificationPage());
  }

  void _goToApprovedHistory(BuildContext context) {
    AppNavigator.push(
      context,
      const AdminVerificationHistoryPage(
        initialStatus: AdminHistoryStatus.approved,
      ),
    );
  }

  void _goToRejectedHistory(BuildContext context) {
    AppNavigator.push(
      context,
      const AdminVerificationHistoryPage(
        initialStatus: AdminHistoryStatus.rejected,
      ),
    );
  }

  void _showPendingNotice(AdminPendingRequestNotice notice) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: RoleTheme.admin.primary,
        margin: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        content: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    notice.message,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildPanelContent() {
    final panel = switch (_controller.selectedPanel) {
      AdminPanelType.pending => AdminPendingPanel(
        key: const ValueKey('pending-panel'),
        onEntrepreneurs: () => _goToEntrepreneurVerification(context),
        onNutritionists: () => _goToNutritionistVerification(context),
      ),
      AdminPanelType.history => AdminHistoryPanel(
        key: const ValueKey('history-panel'),
        onApproved: () => _goToApprovedHistory(context),
        onRejected: () => _goToRejectedHistory(context),
      ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: panel,
    );
  }

  AppBar _buildAppBar(bool isTablet, RolePalette palette) {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      backgroundColor: palette.surface,
      surfaceTintColor: palette.surface,
      title: Text(
        'Panel administrativo',
        style: TextStyle(
          fontSize: isTablet ? 20 : 19.sp,
          fontWeight: FontWeight.w900,
          color: palette.text,
        ),
      ),
      actions: [AdminLogoutButton()],
    );
  }

  Widget _buildPageContent(bool isTablet, RolePalette palette) {
    return RefreshIndicator(
      color: palette.primary,
      onRefresh: _controller.refresh,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 28 : 22.w,
          vertical: isTablet ? 24 : 20.h,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 560 : double.infinity,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AdminHeader(),
              _vGap(18),
              AdminPendingOverview(
                entrepreneurStream: _controller.entrepreneurPendingStream,
                nutritionistStream: _controller.nutritionistPendingStream,
              ),
              _vGap(20),
              AdminPanelNavigator(
                selectedPanel: _controller.selectedPanel,
                onChanged: _controller.setPanel,
              ),
              _vGap(16),
              _buildPanelContent(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    const palette = RoleTheme.admin;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: palette.background,
          appBar: _buildAppBar(isTablet, palette),
          body: SafeArea(
            child: Center(child: _buildPageContent(isTablet, palette)),
          ),
        );
      },
    );
  }
}
