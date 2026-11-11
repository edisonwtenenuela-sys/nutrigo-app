import 'dart:async';

import 'package:emprendedor/features/auth/controllers/user_session_initializer_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserSessionInitializerController', () {
    test('startListening forwards auth user changes to sync handler', () async {
      final streamController = StreamController<String?>();
      final received = <String?>[];
      final controller = UserSessionInitializerController(
        authUserIdStream: streamController.stream,
      );

      controller.startListening(
        onUserChanged: (userId) async {
          received.add(userId);
        },
      );

      streamController.add('user-1');
      streamController.add(null);
      await pumpEventQueue();

      expect(received, ['user-1', null]);

      await controller.dispose();
      await streamController.close();
    });

    test('dispose stops forwarding auth changes', () async {
      final streamController = StreamController<String?>();
      final received = <String?>[];
      final controller = UserSessionInitializerController(
        authUserIdStream: streamController.stream,
      );

      controller.startListening(
        onUserChanged: (userId) async {
          received.add(userId);
        },
      );

      await controller.dispose();
      streamController.add('user-after-dispose');
      await pumpEventQueue();

      expect(received, isEmpty);

      await streamController.close();
    });
  });
}
