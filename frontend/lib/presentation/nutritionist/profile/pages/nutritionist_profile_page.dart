import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';
import 'package:emprendedor/features/nutritionist/controllers/nutritionist_profile_controller.dart';
import 'package:emprendedor/features/nutritionist/controllers/nutritionist_profile_screen_controller.dart';
import 'package:emprendedor/presentation/nutritionist/profile/pages/nutritionist_profile_edit_page.dart';
import 'package:emprendedor/presentation/nutritionist/profile/widgets/layout/nutritionist_consultation_summary_card.dart';
import 'package:emprendedor/presentation/nutritionist/profile/widgets/layout/nutritionist_profile_hero.dart';
import 'package:emprendedor/presentation/nutritionist/profile/widgets/layout/nutritionist_profile_info_section.dart';
import 'package:emprendedor/presentation/nutritionist/profile/widgets/layout/nutritionist_reviews_preview_card.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class NutritionistProfilePage extends StatefulWidget {
  const NutritionistProfilePage({super.key});

  @override
  State<NutritionistProfilePage> createState() =>
      _NutritionistProfilePageState();
}

class _NutritionistProfilePageState extends State<NutritionistProfilePage> {
  final NutritionistProfileScreenController _screenController =
  NutritionistProfileScreenController();

  bool _loaded = false;

  Widget _vGap(double value) => SizedBox(height: value.h);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loaded) return;

    _loaded = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _screenController.loadProfile(
        context.read<NutritionistProfileController>(),
      );
    });
  }

  Future<void> _goToEditProfile() async {
    final controller = context.read<NutritionistProfileController>();
    final viewData = _screenController.buildViewData(controller);

    if (!viewData.canEdit) {
      final result = _screenController.lockedEditResult();

      showAppSnackMessage(
        context,
        role: AppFeedbackRole.nutritionist,
        type: result.type.toPresentationType(),
        message: result.message,
      );
      return;
    }

    await AppNavigator.push(context, const NutritionistProfileEditPage());

    if (!mounted) return;

    await _screenController.loadProfile(controller);
  }

  Future<void> _changePhoto(NutritionistProfileController controller) async {
    final result = await _screenController.changePhoto(controller);

    if (!mounted || result.success) return;

    showAppMessage(
      context,
      role: AppFeedbackRole.nutritionist,
      type: result.type.toPresentationType(),
      title: result.title,
      message: result.message,
    );
  }

  Widget _buildContactSection(
      NutritionistProfileModel? profile,
      NutritionistProfileViewData viewData,
      ) {
    return NutritionistProfileInfoSection(
      title: 'Contacto',
      icon: Icons.contact_phone_rounded,
      children: [
        NutritionistProfileInfoRow(
          icon: Icons.phone_outlined,
          title: 'Teléfono / WhatsApp',
          value: profile?.phone,
        ),
        if (viewData.contactEmail.isNotEmpty)
          NutritionistProfileInfoRow(
            icon: Icons.alternate_email_rounded,
            title: 'Correo electrónico',
            value: viewData.contactEmail,
          ),
      ],
    );
  }

  Widget _buildProfessionalSection(
      NutritionistProfileModel? profile,
      NutritionistProfileViewData viewData,
      ) {
    return NutritionistProfileInfoSection(
      title: 'Información profesional',
      icon: Icons.workspace_premium_rounded,
      children: [
        NutritionistProfileInfoRow(
          icon: Icons.workspace_premium_outlined,
          title: 'Especialidad',
          value: profile?.specialty,
        ),
        NutritionistProfileInfoRow(
          icon: Icons.verified_user_outlined,
          title: 'Registro profesional',
          value: viewData.registryValue,
        ),
        NutritionistProfileInfoRow(
          icon: Icons.description_outlined,
          title: 'Descripción profesional',
          value: profile?.professionalDescription,
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildEditButton(
      RolePalette palette,
      NutritionistProfileViewData viewData,
      ) {
    final color = viewData.canEdit ? palette.primary : palette.mutedText;

    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton.icon(
        onPressed: _goToEditProfile,
        icon: Icon(
          viewData.editButtonIcon,
          color: RoleTheme.iconColorFor(
            viewData.editButtonIcon,
            fallback: color,
          ),
          size: 18.sp,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          backgroundColor: color.withValues(alpha: 0.045),
          side: BorderSide(
            color: color.withValues(alpha: 0.22),
            width: 1.1.w,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
        label: Text(
          viewData.editButtonText,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(RolePalette palette) {
    return Center(
      child: CircularProgressIndicator(color: palette.primary),
    );
  }

  Widget _buildProfileContent(
      NutritionistProfileController controller,
      RolePalette palette,
      ) {
    final profile = controller.currentProfile;
    final isVerified = controller.isVerified;
    final viewData = _screenController.buildViewData(controller);

    return RefreshIndicator(
      color: palette.primary,
      onRefresh: () => _screenController.loadProfile(controller),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 18.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NutritionistProfileHero(
              profile: profile,
              isVerified: isVerified,
              isUploadingImage: controller.isUploadingImage,
              onChangePhoto: () => _changePhoto(controller),
            ),
            _vGap(14),
            NutritionistConsultationSummaryCard(
              profile: profile,
              isVerified: isVerified,
            ),
            _vGap(14),
            NutritionistReviewsPreviewCard(profile: profile),
            _vGap(14),
            _buildContactSection(profile, viewData),
            _vGap(12),
            _buildProfessionalSection(profile, viewData),
            _vGap(16),
            _buildEditButton(palette, viewData),
          ],
        ),
      ),
    );
  }

  Widget _buildPageBody(
      NutritionistProfileController controller,
      RolePalette palette,
      ) {
    if (controller.isLoadingProfile && controller.currentProfile == null) {
      return _buildLoadingState(palette);
    }

    return _buildProfileContent(controller, palette);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NutritionistProfileController>();
    const palette = RoleTheme.nutritionist;

    return _buildPageBody(controller, palette);
  }
}