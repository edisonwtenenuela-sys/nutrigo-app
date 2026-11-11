import 'package:emprendedor/core/services/auth/user_session_service.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/social_media_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/social_media_controller.dart';

enum SocialMediaUiState { loading, error, empty, ready }

class SocialMediaActionResult {
  const SocialMediaActionResult({
    required this.success,
    required this.title,
    required this.message,
  });

  final bool success;
  final String title;
  final String message;
}

class SocialMediaScreenController {
  SocialMediaScreenController({UserSessionService? sessionService})
    : _sessionService = sessionService ?? UserSessionService();

  final UserSessionService _sessionService;

  SocialMediaUiState resolveUiState(SocialMediaController controller) {
    final hasNoLinks = controller.socialMediaList.isEmpty;

    if (controller.isLoading && hasNoLinks) return SocialMediaUiState.loading;
    if (controller.errorMessage != null && hasNoLinks) {
      return SocialMediaUiState.error;
    }
    if (hasNoLinks) return SocialMediaUiState.empty;
    return SocialMediaUiState.ready;
  }

  Future<void> load(SocialMediaController controller) async {
    final userId = _sessionService.currentUserId();
    if (userId == null) return;

    await controller.setUserId(userId);
  }

  Future<void> refresh(SocialMediaController controller) async {
    await load(controller);
    await controller.fetchSocialMediaLinks();
  }

  SocialMediaActionResult? requireUserSession() {
    final userId = _sessionService.currentUserId();
    if (userId != null) return null;

    return const SocialMediaActionResult(
      success: false,
      title: 'Sesión requerida',
      message: 'Usuario no autenticado.',
    );
  }

  SocialMediaModel createDraft(SocialMediaType type) {
    return SocialMediaModel(
      type: type,
      url: '',
      userId: _sessionService.currentUserId() ?? '',
    );
  }

  Future<SocialMediaActionResult> addSocialMedia(
    SocialMediaController controller,
    SocialMediaModel socialMedia,
  ) async {
    final success = await controller.addSocialMedia(socialMedia);

    return SocialMediaActionResult(
      success: success,
      title: success ? 'Red actualizada' : 'No se pudo guardar',
      message: success
          ? 'Red agregada correctamente.'
          : controller.errorMessage ?? 'No se pudo agregar.',
    );
  }

  Future<SocialMediaActionResult> updateSocialMedia(
    SocialMediaController controller,
    SocialMediaModel socialMedia,
  ) async {
    final success = await controller.updateSocialMedia(socialMedia);

    return SocialMediaActionResult(
      success: success,
      title: success ? 'Red actualizada' : 'No se pudo guardar',
      message: success
          ? 'Red actualizada correctamente.'
          : controller.errorMessage ?? 'No se pudo actualizar.',
    );
  }

  Future<SocialMediaActionResult> deleteSocialMedia(
    SocialMediaController controller,
    SocialMediaModel socialMedia,
  ) async {
    final id = socialMedia.id;
    if (id == null || id.trim().isEmpty) {
      return const SocialMediaActionResult(
        success: false,
        title: 'No se pudo guardar',
        message: 'No se pudo identificar la red social.',
      );
    }

    final success = await controller.deleteSocialMedia(id);

    return SocialMediaActionResult(
      success: success,
      title: success ? 'Red actualizada' : 'No se pudo guardar',
      message: success
          ? 'Red eliminada correctamente.'
          : controller.errorMessage ?? 'No se pudo eliminar.',
    );
  }
}








