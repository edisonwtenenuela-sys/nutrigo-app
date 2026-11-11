import 'package:emprendedor/core/services/external_url_launcher_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExternalUrlLauncherService', () {
    const service = ExternalUrlLauncherService();

    test('parseExternalUrl returns null for empty values', () {
      expect(service.parseExternalUrl(null), isNull);
      expect(service.parseExternalUrl('   '), isNull);
    });

    test('parseExternalUrl trims valid URLs', () {
      final uri = service.parseExternalUrl('  https://example.com/path  ');

      expect(uri, isNotNull);
      expect(uri.toString(), 'https://example.com/path');
    });
  });
}
