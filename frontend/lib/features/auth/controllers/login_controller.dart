import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';
import 'package:emprendedor/core/services/external_url_launcher_service.dart';
import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:emprendedor/features/auth/helpers/register_validators.dart';

class LoginController extends ChangeNotifier {
  LoginController({ExternalUrlLauncherService? urlLauncher})
    : _urlLauncher = urlLauncher ?? const ExternalUrlLauncherService();

  final ExternalUrlLauncherService _urlLauncher;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger('LoginController');

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String? errorMessage;
  bool isLoading = false;
  bool obscurePassword = true;
  bool _disposed = false;

  static const String _googleRegistrationRequiredMessage =
      'Esta cuenta Google aún no está registrada. Ve a Regístrate y crea tu cuenta primero.';

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    if (_disposed) return;
    obscurePassword = !obscurePassword;
    _safeNotify();
  }

  void clearError() {
    _setError(null);
  }

  void _setLoading(bool value) {
    if (_disposed || isLoading == value) return;
    isLoading = value;
    _safeNotify();
  }

  void _setError(String? message) {
    if (_disposed || errorMessage == message) return;
    errorMessage = message;
    _safeNotify();
  }

  String? validateEmail(String? value) {
    return RegisterValidators.email(value);
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu contraseña.';
    if (value.length < 6) return 'Mínimo 6 caracteres.';
    return null;
  }

  Future<bool> signInWithEmail({bool requireAdminRole = false}) async {
    _setError(null);

    if (!(formKey.currentState?.validate() ?? false)) {
      return false;
    }

    _setLoading(true);

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        _setError('Error inesperado');
        return false;
      }

      final role = await _registeredProfileRole(uid);
      if (role == null) {
        await _auth.signOut();
        _setError('No existe una cuenta con este correo. Regístrate primero.');
        return false;
      }

      if (requireAdminRole && !_isAdminRole(role)) {
        await _auth.signOut();
        _setError('Esta cuenta no tiene permisos de administrador.');
        return false;
      }

      logger.info('Login exitoso');
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_emailAuthMessage(e));
      logger.severe('Error login: ${e.code}');
      return false;
    } catch (e) {
      _setError('No se pudo iniciar sesión. ${friendlyErrorMessage(e)}');
      logger.severe('Error general: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setError(null);
    _setLoading(true);
    var signedInWithGoogle = false;

    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        logger.info('Usuario canceló Google Sign-In');
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      signedInWithGoogle = true;

      final uid = userCredential.user?.uid;
      logger.info('UID Google: $uid');

      if (uid == null) {
        _setError(_googleRegistrationRequiredMessage);
        logger.info('MENSAJE GOOGLE: $_googleRegistrationRequiredMessage');

        await _disconnectGoogle(googleSignIn);
        await _auth.signOut();

        return false;
      }

      final exists = await _hasRegisteredProfile(uid);
      logger.info('Perfil registrado: $exists');

      if (!exists) {
        _setError(_googleRegistrationRequiredMessage);
        logger.info('MENSAJE GOOGLE: $_googleRegistrationRequiredMessage');

        try {
          await userCredential.user?.delete();
          logger.info('Usuario temporal eliminado de Firebase Auth');
        } catch (e) {
          logger.warning('No se pudo eliminar usuario temporal: $e');
        }

        await Future.delayed(const Duration(milliseconds: 300));
        await _disconnectGoogle(googleSignIn);
        await _auth.signOut();

        return false;
      }

      logger.info('Login Google OK');
      return true;
    } on FirebaseAuthException catch (e) {
      if (signedInWithGoogle) {
        await _disconnectGoogle(GoogleSignIn());
        await _auth.signOut();
      }

      _setError(_googleAuthMessage(e));
      return false;
    } catch (e) {
      if (signedInWithGoogle) {
        await _disconnectGoogle(GoogleSignIn());
        await _auth.signOut();
      }

      _setError('No se pudo continuar con Google. ${friendlyErrorMessage(e)}');
      logger.severe('Google error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _disconnectGoogle(GoogleSignIn googleSignIn) async {
    try {
      await googleSignIn.disconnect();
    } catch (_) {
      await googleSignIn.signOut();
    }
  }

  Future<String?> resetPassword() async {
    final email = emailController.text.trim();
    final emailError = validateEmail(email);

    if (emailError != null) return emailError;

    _setLoading(true);

    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } catch (e) {
      return 'No se pudo enviar el correo. ${friendlyErrorMessage(e)}';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> launchExternalUrl(String urlString) async {
    final opened = await _urlLauncher.openExternalUrl(urlString);
    if (!opened) {
      logger.severe('Error abriendo URL: $urlString');
    }
    return opened;
  }

  String _emailAuthMessage(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' =>
        'No existe una cuenta con este correo. Regístrate primero.',
      'wrong-password' => 'Contraseña incorrecta',
      'invalid-credential' => 'Credenciales inválidas',
      'network-request-failed' =>
        'No hay conexión con el servicio. Revisa tu internet e inténtalo nuevamente.',
      'too-many-requests' =>
        'Se realizaron demasiados intentos. Espera unos minutos e inténtalo nuevamente.',
      'user-disabled' => 'Esta cuenta está deshabilitada.',
      'invalid-email' => 'Ingresa un correo válido.',
      _ => friendlyErrorMessage(
        e,
        fallback: 'No se pudo iniciar sesión. Inténtalo nuevamente.',
      ),
    };
  }

  String _googleAuthMessage(FirebaseAuthException e) {
    return switch (e.code) {
      'account-exists-with-different-credential' =>
        'Cuenta ya existe con otro método',
      'invalid-credential' => 'Credencial inválida',
      'network-request-failed' =>
        'No hay conexión con el servicio. Revisa tu internet e inténtalo nuevamente.',
      _ => friendlyErrorMessage(
        e,
        fallback: 'No se pudo continuar con Google.',
      ),
    };
  }

  Future<bool> _hasRegisteredProfile(String uid) async {
    final role = await _registeredProfileRole(uid);
    return role != null;
  }

  Future<String?> _registeredProfileRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) return null;

      final data = doc.data();
      final role = data?['role']?.toString().trim().toLowerCase();
      if (role == null || role.isEmpty) return null;

      const validRoles = {
        'cliente',
        'client',
        'usuario',
        'emprendedor',
        'entrepreneur',
        'business',
        'nutricionista',
        'nutritionist',
        'pending_nutritionist',
        'admin',
        'administrador',
      };

      return validRoles.contains(role) ? role : null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        logger.warning('PERMISSION_DENIED al leer perfil');
        return null;
      }
      rethrow;
    }
  }

  bool _isAdminRole(String role) {
    return role == 'admin' || role == 'administrador';
  }

  @override
  void dispose() {
    _disposed = true;
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
