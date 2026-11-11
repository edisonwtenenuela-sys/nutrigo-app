import 'package:emprendedor/core/services/external_url_launcher_service.dart';

class SocialLinkLauncherController {
  const SocialLinkLauncherController({
    ExternalUrlLauncherService launcher = const ExternalUrlLauncherService(),
  }) : _launcher = launcher;

  final ExternalUrlLauncherService _launcher;

  String? normalizeUrl(String? rawUrl) {
    final value = rawUrl?.trim();
    if (value == null || value.isEmpty) return null;

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    return 'https://$value';
  }

  Future<bool> openSocialLink(String? rawUrl) {
    return _launcher.openExternalUrl(normalizeUrl(rawUrl));
  }
}








