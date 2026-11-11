import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserSessionInfo {
  const UserSessionInfo({required this.role, required this.isVerified});

  final String? role;
  final bool isVerified;
}

class UserSessionSnapshot {
  const UserSessionSnapshot({
    required this.uid,
    required this.email,
    required this.phoneNumber,
    required this.displayName,
    required this.emailVerified,
    required this.providerIds,
  });

  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final bool emailVerified;
  final Set<String> providerIds;

  bool get isPhoneOnly =>
      providerIds.contains('phone') &&
      !providerIds.contains('password') &&
      !providerIds.contains('google.com');

  bool get isPhoneAuth => providerIds.contains('phone');
  bool get isGoogleAuth => providerIds.contains('google.com');
  bool get isPasswordAuth => providerIds.contains('password');
}

class UserSessionService {
  UserSessionService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  UserSessionSnapshot? currentSnapshot() {
    final user = _auth.currentUser;
    if (user == null) return null;

    return UserSessionSnapshot(
      uid: user.uid,
      email: user.email,
      phoneNumber: user.phoneNumber,
      displayName: user.displayName,
      emailVerified: user.emailVerified,
      providerIds: user.providerData
          .map((provider) => provider.providerId)
          .toSet(),
    );
  }

  String? currentUserId() => _auth.currentUser?.uid;

  Future<UserSessionSnapshot?> reloadCurrentSnapshot() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    await user.reload();
    return currentSnapshot();
  }

  Future<void> updateCurrentPhotoUrl(String imageUrl) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No hay usuario autenticado.');
    }

    await user.updatePhotoURL(imageUrl);
  }

  Future<void> sendCurrentUserEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No hay usuario autenticado.');
    }

    await user.sendEmailVerification();
  }

  Stream<String?> authUserIdChanges() {
    return _auth.authStateChanges().map((user) => user?.uid).distinct();
  }

  Future<bool> isEntrepreneurVerified(String userId) async {
    final sessionInfo = await loadSessionInfo(userId);
    return sessionInfo?.isVerified == true;
  }

  Stream<bool> watchNutritionistVerified(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      final data = doc.data();
      return data?['role'] == 'nutricionista';
    }).distinct();
  }

  Future<UserSessionInfo?> loadSessionInfo(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();
    if (data == null) return null;

    return UserSessionInfo(
      role: data['role']?.toString().trim(),
      isVerified: data['isVerified'] == true,
    );
  }
}








