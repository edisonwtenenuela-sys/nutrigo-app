import 'package:emprendedor/features/entrepreneur/controllers/social_link_launcher_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SocialLinkLauncherController', () {
    const controller = SocialLinkLauncherController();

    test('normalizeUrl returns null for empty values', () {
      expect(controller.normalizeUrl(null), isNull);
      expect(controller.normalizeUrl('   '), isNull);
    });

    test('normalizeUrl keeps explicit schemes', () {
      expect(
        controller.normalizeUrl('https://instagram.com/nutrigo'),
        'https://instagram.com/nutrigo',
      );
      expect(
        controller.normalizeUrl('http://example.com'),
        'http://example.com',
      );
    });

    test('normalizeUrl adds https when scheme is missing', () {
      expect(
        controller.normalizeUrl('instagram.com/nutrigo'),
        'https://instagram.com/nutrigo',
      );
    });
  });
}
