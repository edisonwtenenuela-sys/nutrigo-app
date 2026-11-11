import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/nutritionist/controllers/nutritionist_profile_controller.dart';
import 'package:emprendedor/presentation/nutritionist/profile/widgets/form/nutritionist_consultation_section.dart';
import 'package:emprendedor/presentation/nutritionist/profile/widgets/form/nutritionist_professional_section.dart';
import 'package:emprendedor/presentation/nutritionist/profile/widgets/form/nutritionist_save_button.dart';
import 'package:emprendedor/presentation/nutritionist/profile/widgets/state/nutritionist_admin_note_card.dart';
import 'package:emprendedor/presentation/nutritionist/profile/widgets/state/nutritionist_verification_status_card.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';
import 'package:emprendedor/presentation/shared/widgets/profile_email_verification_card.dart';

class NutritionistProfileForm extends StatelessWidget {
  const NutritionistProfileForm({super.key});

  static const _footerText = 'Los cambios se reflejarán en tu perfil público.';

  bool _isFirstProfessionalSubmission(
      NutritionistProfileController controller,
      ) {
    final profile = controller.currentProfile;

    if (profile == null) return true;

    final hasSpecialty = profile.specialty?.trim().isNotEmpty ?? false;
    final hasLicense = profile.licenseNumber?.trim().isNotEmpty ?? false;
    final hasDescription =
        profile.professionalDescription?.trim().isNotEmpty ?? false;
    final hasPrice = profile.consultationPrice != null;

    return !hasSpecialty || !hasLicense || !hasDescription || !hasPrice;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NutritionistProfileController>();
    final showAdminNote =
        !controller.isVerified && _isFirstProfessionalSubmission(controller);
    const palette = RoleTheme.nutritionist;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(18.w, 6.h, 18.w, 18.h),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NutritionistVerificationStatusCard(
              isVerified: controller.isVerified,
            ),
            SizedBox(height: 18.h),
            const ProfileEmailVerificationCard(
              role: AppFeedbackRole.nutritionist,
            ),
            SizedBox(height: 18.h),
            const _FormSectionCard(child: NutritionistProfessionalSection()),
            SizedBox(height: 18.h),
            const _FormSectionCard(child: NutritionistConsultationSection()),
            SizedBox(height: 18.h),
            if (showAdminNote) ...[
              const NutritionistAdminNoteCard(),
              SizedBox(height: 16.h),
            ],
            const NutritionistSaveButton(),
            SizedBox(height: 10.h),
            Center(
              child: Text(
                _footerText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.mutedText,
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormSectionCard extends StatelessWidget {
  final Widget child;

  const _FormSectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: child,
    );
  }
}