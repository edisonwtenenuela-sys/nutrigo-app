import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/auth/controllers/auth_session_controller.dart';
import 'package:emprendedor/features/client/controllers/client_profile_controller.dart';
import 'package:emprendedor/presentation/client/profile/widgets/account/profile_email_info.dart';
import 'package:emprendedor/presentation/client/profile/widgets/layout/client_profile_section_card.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';
import 'package:emprendedor/presentation/shared/widgets/profile_email_verification_card.dart';

class ClientProfileAccountSection extends StatelessWidget {
  final ClientProfileController controller;
  final UserSessionSnapshot? session;
  final bool shouldShowEmailVerificationCard;
  final VoidCallback onVerificationChanged;

  const ClientProfileAccountSection({
    super.key,
    required this.controller,
    required this.session,
    required this.shouldShowEmailVerificationCard,
    required this.onVerificationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final authPhone = session?.phoneNumber?.trim() ?? '';
    final authEmail = session?.email?.trim() ?? '';
    final contactEmail = controller.emailController.text.trim();
    final isPhoneRegister = session?.isPhoneOnly ?? false;

    return ClientProfileSectionCard(
      title: 'Cuenta',
      icon: Icons.verified_user_rounded,
      children: [
        ProfileEmailInfo(
          value: isPhoneRegister ? authPhone : authEmail,
          isVerified: isPhoneRegister || (session?.emailVerified ?? false),
          label: isPhoneRegister ? 'Teléfono de acceso' : 'Correo de acceso',
          icon: isPhoneRegister ? Icons.phone_rounded : Icons.email_rounded,
          verifiedText: isPhoneRegister ? 'Número verificado' : 'Verificado',
        ),
        if (isPhoneRegister && contactEmail.isNotEmpty) ...[
          SizedBox(height: 10.h),
          ProfileEmailInfo(
            value: contactEmail,
            isVerified: false,
            label: 'Correo de contacto',
            icon: Icons.email_rounded,
          ),
        ],
        if (shouldShowEmailVerificationCard)
          _EmailVerificationSection(
            controller: controller,
            session: session,
            onVerificationChanged: onVerificationChanged,
          ),
      ],
    );
  }
}

class _EmailVerificationSection extends StatelessWidget {
  final ClientProfileController controller;
  final UserSessionSnapshot? session;
  final VoidCallback onVerificationChanged;

  const _EmailVerificationSection({
    required this.controller,
    required this.session,
    required this.onVerificationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final uid = session?.uid;

    if (uid == null) {
      return Padding(
        padding: EdgeInsets.only(top: 10.h),
        child: ProfileEmailVerificationCard(
          role: AppFeedbackRole.client,
          onVerificationChanged: onVerificationChanged,
          compact: true,
        ),
      );
    }

    return StreamBuilder<String?>(
      stream: controller.watchPendingEmail(uid),
      builder: (context, snapshot) {
        final pendingEmail = snapshot.data?.trim() ?? '';
        final hasPending = pendingEmail.isNotEmpty;

        if (hasPending) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: RoleTheme.iconWarning.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: RoleTheme.iconWarning.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16.sp,
                        color: RoleTheme.iconWarning,
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          'Correo pendiente de verificación',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: RoleTheme.iconWarning,
                            fontSize: 11.8.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Offstage(
                offstage: true,
                child: ProfileEmailVerificationCard(
                  role: AppFeedbackRole.client,
                  onVerificationChanged: onVerificationChanged,
                  compact: true,
                ),
              ),
            ],
          );
        }

        return Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: ProfileEmailVerificationCard(
            role: AppFeedbackRole.client,
            onVerificationChanged: onVerificationChanged,
            compact: true,
          ),
        );
      },
    );
  }
}