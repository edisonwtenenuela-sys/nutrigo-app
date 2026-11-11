import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/auth/controllers/profile_email_verification_controller.dart';
import 'package:emprendedor/presentation/auth/pages/auth_wrapper.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class ProfileEmailVerificationCard extends StatefulWidget {
  final AppFeedbackRole role;
  final String title;
  final VoidCallback? onVerificationChanged;
  final bool compact;

  const ProfileEmailVerificationCard({
    super.key,
    required this.role,
    this.title = 'Correo electrónico',
    this.onVerificationChanged,
    this.compact = false,
  });

  @override
  State<ProfileEmailVerificationCard> createState() =>
      _ProfileEmailVerificationCardState();
}

class _ProfileEmailVerificationCardState
    extends State<ProfileEmailVerificationCard>
    with WidgetsBindingObserver {
  late final ProfileEmailVerificationController _controller;

  RolePalette get _palette => appFeedbackPalette(widget.role);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = ProfileEmailVerificationController(
      onVerificationChanged: widget.onVerificationChanged,
    );
    _controller.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _handleResume();
  }

  Future<void> _handleResume() async {
    final result = await _controller.handleResume();

    if (!mounted) return;

    if (result.action == ProfileEmailResumeAction.sessionRecoveryRequired) {
      await showAppMessage(
        context,
        role: widget.role,
        type: AppFeedbackType.info,
        title: 'Verificación aplicada',
        message:
            'Tu correo ya fue confirmado. Por seguridad, inicia sesión nuevamente.',
      );

      if (!mounted) return;
      AppNavigator.replaceAll(context, const AuthWrapper());
    }
  }

  Future<void> _sendVerificationEmail() async {
    final result = await _controller.sendVerificationEmail();

    if (!mounted || result.type == ProfileEmailSendType.none) return;

    final type = switch (result.type) {
      ProfileEmailSendType.success => AppFeedbackType.success,
      ProfileEmailSendType.warning => AppFeedbackType.warning,
      ProfileEmailSendType.error => AppFeedbackType.error,
      ProfileEmailSendType.none => AppFeedbackType.info,
    };

    await showAppMessage(
      context,
      role: widget.role,
      type: type,
      title: result.title ?? 'Listo',
      message: result.message ?? '',
    );
  }

  String get _verificationHelpText {
    switch (widget.role) {
      case AppFeedbackRole.entrepreneur:
        return 'La aprobación del negocio es independiente. Esta verificación confirma tu correo para recuperación y notificaciones.';
      case AppFeedbackRole.nutritionist:
        return 'La aprobación profesional es independiente. Esta verificación confirma tu correo para recuperación y notificaciones.';
      case AppFeedbackRole.client:
        return 'Esta verificación confirma tu correo para recuperación y notificaciones.';
      case AppFeedbackRole.admin:
      case AppFeedbackRole.auth:
        return 'Esta verificación confirma tu correo de acceso.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final isContactMode = _controller.isPhoneContactMode;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(13.w),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.compact) ...[
                Text(
                  isContactMode ? 'Número telefónico' : widget.title,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 9.h),
                TextFormField(
                  controller: _controller.emailController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: _controller.fieldLabel,
                    prefixIcon: Icon(
                      isContactMode ? Icons.phone_rounded : Icons.email_rounded,
                      color: palette.primary,
                    ),
                    filled: true,
                    fillColor: palette.primary.withValues(alpha: 0.035),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
              ],
              if (isContactMode)
                const _StatusChip(
                  text: 'Número verificado',
                  icon: Icons.verified_rounded,
                  background: Color(0xFFE7F8EE),
                  foreground: Color(0xFF168A45),
                )
              else if (_controller.isVerified)
                const _StatusChip(
                  text: 'Correo verificado',
                  icon: Icons.verified_rounded,
                  background: Color(0xFFE7F8EE),
                  foreground: Color(0xFF168A45),
                )
              else if (_controller.showPendingState)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _StatusChip(
                      text: 'Solicitud enviada. Revisa tu correo.',
                      icon: Icons.schedule_rounded,
                      background: Color(0xFFFFF4E6),
                      foreground: Color(0xFFB4690E),
                    ),
                    SizedBox(height: 8.h),
                    _VerificationHelpText(
                      text: _verificationHelpText,
                      palette: palette,
                    ),
                  ],
                )
              else if (_controller.showVerifyButton)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _VerificationButton(
                      isLoading: _controller.isSendingVerification,
                      onPressed: _sendVerificationEmail,
                      palette: palette,
                    ),
                    SizedBox(height: 8.h),
                    _VerificationHelpText(
                      text: _verificationHelpText,
                      palette: palette,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _VerificationHelpText extends StatelessWidget {
  final String text;
  final RolePalette palette;

  const _VerificationHelpText({required this.text, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: palette.mutedText,
        fontSize: 10.6.sp,
        fontWeight: FontWeight.w600,
        height: 1.28,
      ),
    );
  }
}

class _VerificationButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final RolePalette palette;

  const _VerificationButton({
    required this.isLoading,
    required this.onPressed,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40.h,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 16.w,
                height: 16.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: palette.primary,
                ),
              )
            : Icon(
          Icons.mark_email_unread_rounded,
          color: palette.primary,
          size: 17.sp,
        ),
        label: Text(
          isLoading ? 'Enviando...' : 'Verificar correo de acceso',
          style: TextStyle(fontSize: 11.8.sp, fontWeight: FontWeight.w900),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          backgroundColor: palette.primary.withValues(alpha: 0.055),
          side: BorderSide(color: palette.primary.withValues(alpha: 0.18)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color background;
  final Color foreground;

  const _StatusChip({
    required this.text,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15.sp, color: foreground),
          SizedBox(width: 7.w),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: foreground,
                fontSize: 11.8.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}








