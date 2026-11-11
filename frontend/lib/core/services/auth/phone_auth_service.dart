import 'package:firebase_auth/firebase_auth.dart';
import 'package:emprendedor/core/utils/auth/phone_auth_helpers.dart';

class PhoneAuthFailure implements Exception {
  const PhoneAuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class PhoneAuthSignInResult {
  const PhoneAuthSignInResult({
    required this.userId,
    required this.isNewUser,
  });

  final String userId;
  final bool isNewUser;
}

class PhoneAuthService {
  PhoneAuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Future<void> Function(PhoneAuthSignInResult result)
    onVerificationCompleted,
    required void Function(String message) onVerificationFailed,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String verificationId) onAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) async {
          try {
            final result = await _signInWithCredential(credential);
            await onVerificationCompleted(result);
          } on PhoneAuthFailure catch (e) {
            onVerificationFailed(e.message);
          } catch (_) {
            onVerificationFailed(
              'Ocurrió un error inesperado. Inténtalo de nuevo.',
            );
          }
        },
        verificationFailed: (e) {
          onVerificationFailed(phoneVerificationFailedMessage(e));
        },
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: onAutoRetrievalTimeout,
      );
    } catch (_) {
      throw const PhoneAuthFailure(
        'Ocurrió un error inesperado. Inténtalo de nuevo.',
      );
    }
  }

  Future<PhoneAuthSignInResult> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    return _signInWithCredential(credential);
  }

  Future<void> waitForAuthenticatedUser() async {
    if (_auth.currentUser != null) return;

    await _auth.authStateChanges().firstWhere((user) => user != null);
  }

  Future<PhoneAuthSignInResult> _signInWithCredential(
      PhoneAuthCredential credential,
      ) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw const PhoneAuthFailure(
          'No se pudo obtener el usuario autenticado.',
        );
      }

      return PhoneAuthSignInResult(
        userId: user.uid,
        isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
      );
    } on FirebaseAuthException catch (e) {
      throw PhoneAuthFailure(phoneSignInErrorMessage(e));
    }
  }
}