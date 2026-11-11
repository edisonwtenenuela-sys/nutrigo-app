import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:emprendedor/core/services/auth/user_session_service.dart';

class AdminDiagnosticsService {
  AdminDiagnosticsService({
    FirebaseFirestore? firestore,
    UserSessionService? sessionService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _sessionService = sessionService ?? UserSessionService();

  final FirebaseFirestore _firestore;
  final UserSessionService _sessionService;

  Future<Map<String, String>> loadDiagnostics() async {
    final session = _sessionService.currentSnapshot();
    final uid = session?.uid ?? 'null';
    final email = session?.email ?? 'null';
    final projectId = Firebase.app().options.projectId;
    String role = 'sin documento';

    if (session != null) {
      final snap = await _firestore.collection('users').doc(session.uid).get();
      final data = snap.data();
      role = (data?['role'] ?? 'sin campo role').toString();
    }

    return {'projectId': projectId, 'uid': uid, 'email': email, 'role': role};
  }
}








