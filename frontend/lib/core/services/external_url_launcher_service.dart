import 'package:url_launcher/url_launcher.dart';

class ExternalUrlLauncherService {
  const ExternalUrlLauncherService();

  Future<bool> openExternalUrl(String? rawUrl) async {
    final uri = parseExternalUrl(rawUrl);
    if (uri == null || !await canLaunchUrl(uri)) return false;

    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Uri? parseExternalUrl(String? rawUrl) {
    final value = rawUrl?.trim();
    if (value == null || value.isEmpty) return null;

    return Uri.tryParse(value);
  }
}








