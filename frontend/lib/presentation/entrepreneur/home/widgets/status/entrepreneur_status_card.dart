import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/entrepreneur/controllers/business_status_controller.dart';
import 'package:emprendedor/presentation/entrepreneur/home/dialogs/entrepreneur_status_dialog.dart';
import 'package:emprendedor/presentation/entrepreneur/home/widgets/status/entrepreneur_status_header.dart';
import 'package:emprendedor/presentation/entrepreneur/home/widgets/status/entrepreneur_status_item.dart';
import 'package:emprendedor/presentation/entrepreneur/home/widgets/status/entrepreneur_verification_button.dart';
import 'package:emprendedor/presentation/entrepreneur/profile/pages/entrepreneur_profile_setup_page.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class BusinessStatusCard extends StatelessWidget {
  BusinessStatusCard({super.key, this.initialVerificationData});

  final Map<String, dynamic>? initialVerificationData;

  final BusinessStatusController _controller = BusinessStatusController();

  Future<void> _openCorrectionForm(BuildContext context) async {
    final userId = _controller.currentUserId();

    if (userId == null) {
      showAppMessage(
        context,
        role: AppFeedbackRole.entrepreneur,
        type: AppFeedbackType.error,
        title: 'Sesión no disponible',
        message: 'Vuelve a iniciar sesión para corregir la solicitud.',
      );
      return;
    }

    await AppNavigator.push(
      context,
      BusinessProfileSetupPage(userId: userId, allowBack: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _controller.watchVerificationData(),
      initialData: initialVerificationData,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final statusData = data == null
            ? _controller.optimisticVerifiedStatus()
            : _controller.resolveStatus(data);

        return _BusinessStatusShell(
          statusIcon: statusData.icon,
          statusTitle: statusData.title,
          statusSubtitle: statusData.subtitle,
          statusColor: statusData.color,
          canRequestVerification: statusData.canRequestVerification,
          onStatusTap: () {
            showBusinessStatusDialog(
              context,
              title: statusData.title,
              message: statusData.subtitle,
              icon: statusData.icon,
            );
          },
          verificationButtonLabel: statusData.title == 'Verificación rechazada'
              ? 'Corregir y reenviar solicitud'
              : 'Completar solicitud',
          onVerificationRequest: () => _openCorrectionForm(context),
        );
      },
    );
  }
}

class _BusinessStatusShell extends StatelessWidget {
  final IconData? statusIcon;
  final String? statusTitle;
  final String? statusSubtitle;
  final Color? statusColor;
  final bool canRequestVerification;
  final VoidCallback? onStatusTap;
  final String verificationButtonLabel;
  final VoidCallback? onVerificationRequest;

  const _BusinessStatusShell({
    this.statusIcon,
    this.statusTitle,
    this.statusSubtitle,
    this.statusColor,
    this.canRequestVerification = false,
    this.onStatusTap,
    this.verificationButtonLabel = 'Completar solicitud',
    this.onVerificationRequest,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(21.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 16.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BusinessStatusHeader(),
          SizedBox(height: 13.h),
          InkWell(
            borderRadius: BorderRadius.circular(15.r),
            onTap: onStatusTap,
            child: BusinessStatusItem(
              icon: statusIcon!,
              title: statusTitle!,
              subtitle: statusSubtitle!,
              color: statusColor!,
              showChevron: true,
            ),
          ),
          if (canRequestVerification) ...[
            SizedBox(height: 11.h),
            BusinessVerificationButton(
              label: verificationButtonLabel,
              icon: Icons.edit_note_rounded,
              onPressed: onVerificationRequest!,
            ),
          ],
          SizedBox(height: 10.h),
          BusinessStatusItem(
            icon: Icons.security_rounded,
            title: 'Cuenta protegida',
            subtitle: 'Seguridad mediante Firebase Auth.',
            color: RoleTheme.iconInfo,
          ),
          SizedBox(height: 8.h),
          BusinessStatusItem(
            icon: Icons.health_and_safety_rounded,
            title: 'Validación nutricional',
            subtitle: 'Productos revisados por nutricionistas.',
            color: palette.secondary,
          ),
        ],
      ),
    );
  }
}
