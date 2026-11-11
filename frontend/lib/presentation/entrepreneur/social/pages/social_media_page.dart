import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/social_media_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';
import 'package:emprendedor/presentation/entrepreneur/social/dialogs/edit_social_media_dialog.dart';
import 'package:emprendedor/presentation/entrepreneur/social/widgets/social_media_add_sheet.dart';
import 'package:emprendedor/presentation/entrepreneur/social/widgets/social_media_card.dart';
import 'package:emprendedor/presentation/entrepreneur/social/widgets/social_media_empty_state.dart';
import 'package:emprendedor/presentation/entrepreneur/social/widgets/social_media_header.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';
import 'package:emprendedor/presentation/shared/widgets/common/app_error_state.dart';

class SocialMediaPage extends StatefulWidget {
  const SocialMediaPage({super.key});

  @override
  State<SocialMediaPage> createState() => _SocialMediaPageState();
}

class _SocialMediaPageState extends State<SocialMediaPage> {
  final SocialMediaScreenController _screenController =
  SocialMediaScreenController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _screenController.load(context.read<SocialMediaController>());
    });
  }

  Future<void> _refresh() async {
    await _screenController.refresh(context.read<SocialMediaController>());
  }

  Widget _buildSocialIcon(SocialMediaType type) {
    const palette = RoleTheme.entrepreneur;

    switch (type) {
      case SocialMediaType.facebook:
        return FaIcon(
          FontAwesomeIcons.facebook,
          color: palette.primary,
          size: 22.sp,
        );

      case SocialMediaType.instagram:
        return FaIcon(
          FontAwesomeIcons.instagram,
          color: palette.primary,
          size: 22.sp,
        );

      case SocialMediaType.whatsapp:
        return FaIcon(
          FontAwesomeIcons.whatsapp,
          color: palette.primary,
          size: 22.sp,
        );

      case SocialMediaType.website:
        return Icon(
          Icons.public,
          color: RoleTheme.iconColorFor(
            Icons.public,
            fallback: palette.primary,
          ),
          size: 22.sp,
        );

      case SocialMediaType.tiktok:
        return FaIcon(
          FontAwesomeIcons.tiktok,
          color: palette.primary,
          size: 22.sp,
        );
    }
  }

  Future<void> _showActionResult(SocialMediaActionResult result) {
    return showAppMessage(
      context,
      role: AppFeedbackRole.entrepreneur,
      type: result.success ? AppFeedbackType.success : AppFeedbackType.error,
      title: result.title,
      message: result.message,
    );
  }

  Future<void> _editSocialMedia(
      SocialMediaController controller,
      SocialMediaModel socialMedia,
      ) async {
    final updatedSocialMedia = await showEditSocialMediaDialog(
      context: context,
      socialMedia: socialMedia,
    );

    if (!mounted || updatedSocialMedia == null) return;

    final result = await _screenController.updateSocialMedia(
      controller,
      updatedSocialMedia,
    );

    if (!mounted) return;
    await _showActionResult(result);
  }

  Future<void> _addSocialMedia(
      SocialMediaController controller,
      SocialMediaType type,
      ) async {
    final socialMedia = await showEditSocialMediaDialog(
      context: context,
      socialMedia: _screenController.createDraft(type),
    );

    if (!mounted || socialMedia == null) return;

    final result = await _screenController.addSocialMedia(
      controller,
      socialMedia,
    );

    if (!mounted) return;
    await _showActionResult(result);
  }

  Future<void> _deleteSocialMedia(
      SocialMediaController controller,
      SocialMediaModel socialMedia,
      ) async {
    final result = await _screenController.deleteSocialMedia(
      controller,
      socialMedia,
    );

    if (!mounted) return;
    await _showActionResult(result);
  }

  void _showAddOptions() {
    const palette = RoleTheme.entrepreneur;

    final sessionError = _screenController.requireUserSession();

    if (sessionError != null) {
      _showActionResult(sessionError);
      return;
    }

    final controller = context.read<SocialMediaController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: palette.text.withValues(alpha: 0.28),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return SocialMediaAddSheet(
          onAdd: (type) => _addSocialMedia(controller, type),
        );
      },
    );
  }

  Widget _buildContent(SocialMediaController controller) {
    const palette = RoleTheme.entrepreneur;
    final uiState = _screenController.resolveUiState(controller);

    if (uiState == SocialMediaUiState.loading) {
      return Center(child: CircularProgressIndicator(color: palette.primary));
    }

    if (uiState == SocialMediaUiState.error) {
      return _buildErrorState(controller);
    }

    if (uiState == SocialMediaUiState.empty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 24.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: SocialMediaEmptyState(onAdd: _showAddOptions),
              ),
            ),
          );
        },
      );
    }

    return _buildSocialMediaList(controller);
  }

  Widget _buildErrorState(SocialMediaController controller) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(24.w),
      children: [
        SizedBox(height: 120.h),
        AppErrorState(
          message: controller.errorMessage ?? 'No se pudieron cargar las redes sociales.',
          onRetry: _refresh,
        ),
      ],
    );
  }

  Widget _buildSocialMediaList(SocialMediaController controller) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 96.h),
      itemCount: controller.socialMediaList.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: SocialMediaHeader(count: controller.socialMediaList.length),
          );
        }

        final socialMedia = controller.socialMediaList[index - 1];

        return SocialMediaCard(
          socialMedia: socialMedia,
          leading: _buildSocialIcon(socialMedia.type),
          onEdit: () => _editSocialMedia(controller, socialMedia),
          onDelete: socialMedia.id == null
              ? null
              : () => _deleteSocialMedia(controller, socialMedia),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;
    final controller = context.watch<SocialMediaController>();

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        surfaceTintColor: palette.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Redes sociales',
          style: TextStyle(
            color: palette.text,
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: palette.primary,
        onRefresh: _refresh,
        child: _buildContent(controller),
      ),
      floatingActionButton: controller.socialMediaList.isEmpty
          ? null
          : _buildFloatingActionButton(palette),
    );
  }

  Widget _buildFloatingActionButton(RolePalette palette) {
    return FloatingActionButton.extended(
      heroTag: 'socialMediaFab',
      elevation: 0,
      backgroundColor: palette.primary.withValues(alpha: 0.055),
      foregroundColor: palette.primary,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: palette.primary.withValues(alpha: 0.18),
        ),
        borderRadius: BorderRadius.circular(18.r),
      ),
      onPressed: _showAddOptions,
      icon: Icon(Icons.add_rounded, size: 20.sp),
      label: Text(
        'Agregar red',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}