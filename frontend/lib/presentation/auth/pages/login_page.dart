import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/auth/controllers/login_controller.dart';
import 'package:emprendedor/features/auth/helpers/login_feedback_gate.dart';
import 'package:emprendedor/presentation/auth/pages/auth_wrapper.dart';
import 'package:emprendedor/presentation/auth/widgets/index.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

double _responsiveSize(num value, double min, double max) =>
    value.clamp(min, max).toDouble();

class LoginPage extends StatefulWidget {
  final String? initialErrorMessage;
  final bool adminOnly;

  const LoginPage({
    super.key,
    this.initialErrorMessage,
    this.adminOnly = false,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const String _termsUrl =
      'https://edisontm1721.github.io/legal-app-saludable/terms.html';
  static const String _privacyUrl =
      'https://edisontm1721.github.io/legal-app-saludable/privacy.html';

  late final LoginController _controller;
  final LoginFeedbackGate _feedbackGate = LoginFeedbackGate();

  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  Widget _vGap(double value) => SizedBox(height: value.h);

  @override
  void initState() {
    super.initState();

    _controller = LoginController();

    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _openUrl(_termsUrl);

    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _openUrl(_privacyUrl);

    _scheduleInitialErrorMessage();
  }

  @override
  void didUpdateWidget(covariant LoginPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    _feedbackGate.resetInitialErrorIfChanged(
      oldWidget.initialErrorMessage,
      widget.initialErrorMessage,
    );
    _scheduleInitialErrorMessage();
  }

  void _scheduleInitialErrorMessage() {
    final initialMessage = _feedbackGate.consumeInitialError(
      widget.initialErrorMessage,
    );

    if (initialMessage == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showMessage(initialMessage, isError: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _goToAuthWrapperAfterLogin() async {
    await Future.delayed(LoginFeedbackGate.authRedirectDelay);

    if (!mounted) return;

    await AppNavigator.replaceAll(context, const AuthWrapper());
  }

  Future<void> _handleEmailLogin() async {
    final success = await _controller.signInWithEmail(
      requireAdminRole: widget.adminOnly,
    );

    if (!mounted) return;

    if (success) {
      await _goToAuthWrapperAfterLogin();
      return;
    }

    final message = _controller.errorMessage;

    if (message != null && message.trim().isNotEmpty) {
      _showMessage(message, isError: true);
    }
  }

  Future<void> _handleGoogleLogin() async {
    final success = await _controller.signInWithGoogle();

    if (!mounted) return;

    if (success) {
      await _goToAuthWrapperAfterLogin();
      return;
    }

    final message =
        _controller.errorMessage ??
        'Esta cuenta de Google aún no está registrada. Ve a Regístrate y crea tu cuenta primero.';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showMessage(message, isError: true);
    });
  }

  Future<void> _handleResetPassword() async {
    final result = await _controller.resetPassword();

    if (!mounted) return;

    _showMessage(
      result ?? 'Correo de restablecimiento enviado.',
      isError: result != null,
    );
  }

  Future<void> _openUrl(String url) async {
    final opened = await _controller.launchExternalUrl(url);

    if (!mounted) return;

    if (!opened) {
      _showMessage('No se pudo abrir el enlace.', isError: true);
    }
  }

  void _showMessage(String text, {bool isError = false}) {
    if (!mounted || !_feedbackGate.beginMessage()) return;

    showAppMessage(
      context,
      role: AppFeedbackRole.auth,
      type: isError ? AppFeedbackType.error : AppFeedbackType.success,
      title: isError ? 'No se pudo completar' : 'Listo',
      message: text,
    );

    Future.delayed(LoginFeedbackGate.feedbackCooldown, () {
      _feedbackGate.endMessageCooldown();
    });
  }

  Widget _buildLoginCard({
    required bool isTablet,
    required RolePalette palette,
  }) {
    return LoginPrimaryCard(
      palette: palette,
      isTablet: isTablet,
      child: LoginForm(
        controller: _controller,
        palette: palette,
        adminOnly: widget.adminOnly,
        onLogin: _handleEmailLogin,
        onResetPassword: _handleResetPassword,
      ),
    );
  }

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildPageContent({
    required bool isTablet,
    required RolePalette palette,
  }) {
    return SizedBox(
      width: isTablet ? 430.w : double.infinity,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          isTablet ? 20.w : 18.w,
          widget.adminOnly ? 0 : (isTablet ? 8.h : 6.h),
          isTablet ? 20.w : 18.w,
          24.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoginTopBar(
              palette: palette,
              isLoading: _controller.isLoading,
              adminOnly: widget.adminOnly,
              onBack: _goBack,
            ),
            _vGap(widget.adminOnly ? 0 : 6),
            LoginHeader(palette: palette, adminOnly: widget.adminOnly),
            _vGap(18),
            _buildLoginCard(isTablet: isTablet, palette: palette),
            if (!widget.adminOnly) ...[
              _vGap(18),
              LoginSocialButtons(
                controller: _controller,
                onGoogleLogin: _handleGoogleLogin,
              ),
              _vGap(4),
              LoginTermsText(
                termsRecognizer: _termsRecognizer,
                privacyRecognizer: _privacyRecognizer,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdminPageContent({
    required bool isTablet,
    required RolePalette palette,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentWidth = isTablet
        ? _responsiveSize(screenWidth * 0.72, 320, 430)
        : double.infinity;

    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: contentWidth,
            child: LoginTopBar(
              palette: palette,
              isLoading: _controller.isLoading,
              adminOnly: true,
              onBack: _goBack,
            ),
          ),
        ),
        Center(
          child: SizedBox(
            width: contentWidth,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                isTablet ? 20.w : 18.w,
                isTablet ? 36.h : 56.h,
                isTablet ? 20.w : 18.w,
                24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.translate(
                    offset: Offset(0, -18.h),
                    child: _AdminAccessBadge(palette: palette),
                  ),
                  _vGap(2),
                  LoginHeader(palette: palette, adminOnly: true),
                  _vGap(16),
                  _buildLoginCard(isTablet: isTablet, palette: palette),
                  _vGap(18),
                  _AdminTrustFooter(palette: palette),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
    final palette = widget.adminOnly ? RoleTheme.admin : RoleTheme.client;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AuthScreenBackground(
            palette: palette,
            child: SafeArea(
              child: widget.adminOnly
                  ? _buildAdminPageContent(isTablet: isTablet, palette: palette)
                  : Center(
                      child: _buildPageContent(
                        isTablet: isTablet,
                        palette: palette,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _AdminAccessBadge extends StatelessWidget {
  final RolePalette palette;

  const _AdminAccessBadge({required this.palette});

  @override
  Widget build(BuildContext context) {
    final badgeSize = _responsiveSize(70.w, 58, 78);
    final margin = _responsiveSize(7.w, 6, 8);

    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.primary, palette.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.28),
            blurRadius: 26.r,
            offset: Offset(0, 14.h),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.all(margin),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Icon(
          Icons.security_rounded,
          color: Colors.white,
          size: _responsiveSize(34.sp, 28, 36),
        ),
      ),
    );
  }
}

class _AdminTrustFooter extends StatelessWidget {
  final RolePalette palette;

  const _AdminTrustFooter({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.08)),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10.w,
        runSpacing: 8.h,
        children: [
          _AdminTrustItem(
            icon: Icons.verified_user_outlined,
            label: 'Rol validado',
            palette: palette,
          ),
          _AdminTrustItem(
            icon: Icons.lock_outline_rounded,
            label: 'Acceso seguro',
            palette: palette,
          ),
          _AdminTrustItem(
            icon: Icons.manage_accounts_outlined,
            label: 'Gestión administrativa',
            palette: palette,
          ),
        ],
      ),
    );
  }
}

class _AdminTrustItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final RolePalette palette;

  const _AdminTrustItem({
    required this.icon,
    required this.label,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
          size: _responsiveSize(14.sp, 12, 15),
        ),
        SizedBox(width: _responsiveSize(5.w, 4, 6)),
        Text(
          label,
          style: TextStyle(
            color: palette.text.withValues(alpha: 0.78),
            fontSize: _responsiveSize(10.2.sp, 9.5, 11),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
