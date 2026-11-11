import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileEmailData {
  const ProfileEmailData({this.pendingEmail, this.storedEmail});

  final String? pendingEmail;
  final String? storedEmail;
}

class ProfileEmailVerificationFailure implements Exception {
  const ProfileEmailVerificationFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class ProfileEmailSession {
  const ProfileEmailSession({
    required this.uid,
    required this.email,
    required this.phoneNumber,
    required this.emailVerified,
    required this.providerIds,
  });

  final String uid;
  final String? email;
  final String? phoneNumber;
  final bool emailVerified;
  final Set<String> providerIds;

  bool get isPhoneOnly =>
      providerIds.contains('phone') &&
      !providerIds.contains('password') &&
      !providerIds.contains('google.com');

  bool get isGoogle => providerIds.contains('google.com');

  bool get isPassword => providerIds.contains('password');
}

class ProfileEmailVerificationService {
  ProfileEmailVerificationService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ProfileEmailSession? currentSession() {
    return _sessionFromUser(_auth.currentUser);
  }

  Future<ProfileEmailSession?> reloadCurrentSession() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    await user.reload();
    return _sessionFromUser(_auth.currentUser ?? user);
  }

  Future<ProfileEmailData> loadEmailData(String userId) async {
    final snap = await _firestore.collection('users').doc(userId).get();
    final data = snap.data();

    return ProfileEmailData(
      pendingEmail: _clean(data?['pendingEmail']),
      storedEmail: _clean(data?['email']),
    );
  }

  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const ProfileEmailVerificationFailure(
        'Inicia sesión nuevamente para enviar la verificación.',
      );
    }

    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'too-many-requests' =>
          'Se enviaron demasiadas solicitudes. Espera unos minutos e inténtalo nuevamente.',
        'requires-recent-login' =>
          'Por seguridad, inicia sesión nuevamente para enviar la verificación.',
        _ => e.message ?? 'No se pudo enviar el correo de verificación.',
      };
      throw ProfileEmailVerificationFailure(message);
    }
  }

  Future<void> markVerificationEmailSent({
    required String userId,
    required String email,
  }) {
    return _firestore.collection('users').doc(userId).set({
      'pendingEmail': email,
      'emailVerificationSentAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> markEmailVerified({
    required String userId,
    required String email,
  }) {
    return _firestore.collection('users').doc(userId).set({
      'email': email,
      'pendingEmail': FieldValue.delete(),
      'emailVerified': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  ProfileEmailSession? _sessionFromUser(User? user) {
    if (user == null) return null;

    return ProfileEmailSession(
      uid: user.uid,
      email: user.email,
      phoneNumber: user.phoneNumber,
      emailVerified: user.emailVerified,
      providerIds: user.providerData
          .map((provider) => provider.providerId)
          .toSet(),
    );
  }

  String? _clean(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }
}








