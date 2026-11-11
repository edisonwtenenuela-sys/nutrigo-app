import 'package:emprendedor/core/services/auth/user_session_service.dart';
import 'package:emprendedor/features/entrepreneur/controllers/payment_method_controller.dart';
import 'package:emprendedor/features/entrepreneur/controllers/profile_controller.dart';
import 'package:emprendedor/features/entrepreneur/controllers/social_media_controller.dart';

enum BusinessProfileUiState { sessionMissing, loading, error, empty, ready }

class BusinessProfileScreenController {
  BusinessProfileScreenController({UserSessionService? sessionService})
    : _sessionService = sessionService ?? UserSessionService();

  final UserSessionService _sessionService;

  String? currentUserId() => _sessionService.currentUserId();

  BusinessProfileUiState resolveUiState(ProfileController controller) {
    if (currentUserId() == null) return BusinessProfileUiState.sessionMissing;

    final hasProfile = controller.businessProfile != null;

    if (controller.isLoading && !hasProfile) {
      return BusinessProfileUiState.loading;
    }
    if (controller.errorMessage != null && !hasProfile) {
      return BusinessProfileUiState.error;
    }
    if (!hasProfile) return BusinessProfileUiState.empty;
    return BusinessProfileUiState.ready;
  }

  Future<void> load({
    required ProfileController profileController,
    required SocialMediaController socialController,
    required PaymentMethodController paymentController,
  }) async {
    final userId = currentUserId();
    if (userId == null) return;

    await profileController.setUserId(userId);

    if (profileController.businessProfile == null) {
      await profileController.fetchBusinessProfile();
    }

    await Future.wait([
      socialController.setUserId(userId),
      paymentController.setUserId(userId),
    ]);
  }

  Future<void> refresh({
    required ProfileController profileController,
    required SocialMediaController socialController,
    required PaymentMethodController paymentController,
  }) async {
    await profileController.fetchBusinessProfile();

    await Future.wait([
      socialController.fetchSocialMediaLinks(),
      paymentController.fetchPaymentMethods(),
    ]);
  }

  bool hasSocialMedia(SocialMediaController controller) {
    return controller.socialMediaList.any((item) => item.url.trim().isNotEmpty);
  }
}








