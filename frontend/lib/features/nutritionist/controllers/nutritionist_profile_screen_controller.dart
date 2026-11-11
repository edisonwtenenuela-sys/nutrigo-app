import 'package:flutter/material.dart';

import 'package:emprendedor/core/services/auth/user_session_service.dart';
import 'package:emprendedor/core/utils/professional_registry_utils.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';
import 'package:emprendedor/features/nutritionist/controllers/nutritionist_profile_controller.dart';
import 'package:emprendedor/core/feedback/app_feedback_level.dart';

class NutritionistProfileViewData {
  const NutritionistProfileViewData({
    required this.contactEmail,
    required this.registryValue,
    required this.canEdit,
    required this.editButtonText,
    required this.editButtonIcon,
  });

  final String contactEmail;
  final String registryValue;
  final bool canEdit;
  final String editButtonText;
  final IconData editButtonIcon;
}

class NutritionistProfilePhotoResult {
  const NutritionistProfilePhotoResult({
    required this.success,
    required this.type,
    required this.title,
    required this.message,
  });

  final bool success;
  final AppFeedbackLevel type;
  final String title;
  final String message;
}

class NutritionistProfileScreenController {
  NutritionistProfileScreenController({UserSessionService? sessionService})
    : _sessionService = sessionService ?? UserSessionService();

  final UserSessionService _sessionService;

  Future<void> loadProfile(NutritionistProfileController controller) {
    return controller.loadProfile();
  }

  NutritionistProfileViewData buildViewData(
    NutritionistProfileController controller,
  ) {
    final profile = controller.currentProfile;
    final profileEmail = profile?.email?.trim() ?? '';
    final authEmail = _sessionService.currentSnapshot()?.email?.trim() ?? '';
    final contactEmail = profileEmail.isNotEmpty ? profileEmail : authEmail;

    return NutritionistProfileViewData(
      contactEmail: contactEmail,
      registryValue: _registryValue(profile),
      canEdit: controller.isVerified,
      editButtonText: controller.isVerified
          ? 'Editar perfil'
          : 'Edición bloqueada hasta aprobación',
      editButtonIcon: controller.isVerified
          ? Icons.edit_rounded
          : Icons.lock_clock_rounded,
    );
  }

  NutritionistProfilePhotoResult lockedEditResult() {
    return const NutritionistProfilePhotoResult(
      success: false,
      type: AppFeedbackLevel.warning,
      title: 'Perfil pendiente',
      message:
          'La edición se desbloqueará cuando el administrador apruebe tu perfil.',
    );
  }

  Future<NutritionistProfilePhotoResult> changePhoto(
    NutritionistProfileController controller,
  ) async {
    final success = await controller.pickAndUploadProfileImage();

    return NutritionistProfilePhotoResult(
      success: success,
      type: success ? AppFeedbackLevel.success : AppFeedbackLevel.error,
      title: success ? 'Foto actualizada' : 'No se pudo actualizar',
      message: success
          ? 'Foto de perfil actualizada correctamente.'
          : controller.errorMessage ?? 'No se pudo actualizar la foto.',
    );
  }

  String _registryValue(NutritionistProfileModel? profile) {
    final registryType = ProfessionalRegistryUtils.registryTypeLabel(
      profile?.professionalRegistryType ?? '',
    );
    final registryNumber = profile?.licenseNumber?.trim() ?? '';

    return registryNumber.isEmpty ? '' : '$registryType - $registryNumber';
  }
}
