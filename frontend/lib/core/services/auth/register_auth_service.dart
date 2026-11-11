import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:emprendedor/core/utils/auth/register_error_mapper.dart';

class RegisterAuthFailure implements Exception {
  const RegisterAuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class RegisterAuthResult {
  const RegisterAuthResult({
    required this.userId,
    required this.email,
    required this.isNewUser,
    this.displayName,
  });

  final String userId;
  final String email;
  final String? displayName;
  final bool isNewUser;
}

class RegisterAuthService {
  RegisterAuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  Future<RegisterAuthResult> createWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const RegisterAuthFailure('No se pudo crear el usuario.');
      }

      return RegisterAuthResult(
        userId: user.uid,
        email: user.email ?? email,
        displayName: user.displayName,
        isNewUser: credential.additionalUserInfo?.isNewUser ?? true,
      );
    } on FirebaseAuthException catch (e) {
      throw RegisterAuthFailure(registerEmailErrorMessage(e));
    }
  }

  Future<RegisterAuthResult?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw const RegisterAuthFailure(
          'No se pudo obtener el usuario autenticado.',
        );
      }

      return RegisterAuthResult(
        userId: user.uid,
        email: user.email ?? googleUser.email,
        displayName: user.displayName ?? googleUser.displayName,
        isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
      );
    } on FirebaseAuthException catch (e) {
      throw RegisterAuthFailure(registerGoogleErrorMessage(e));
    }
  }

  Future<void> waitForAuthenticatedUser() async {
    if (_auth.currentUser != null) return;

    await _auth.authStateChanges().firstWhere((user) => user != null);
  }
}








