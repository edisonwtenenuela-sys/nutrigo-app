export 'package:emprendedor/core/services/auth/user_session_service.dart'
    show UserSessionSnapshot;
import 'package:flutter/widgets.dart';

import 'package:emprendedor/core/services/auth/auth_logout_service.dart';
import 'package:emprendedor/core/services/auth/user_session_service.dart';

class AuthSessionController {
  AuthSessionController({UserSessionService? sessionService})
    : _sessionService = sessionService ?? UserSessionService();

  final UserSessionService _sessionService;

  String? currentUserId() => _sessionService.currentUserId();

  UserSessionSnapshot? currentSnapshot() => _sessionService.currentSnapshot();

  Stream<String?> authUserIdChanges() => _sessionService.authUserIdChanges();

  Future<void> logout(BuildContext context) => performLogout(context);

  Future<void> signOutOnly() => signOutCurrentSession();
}








