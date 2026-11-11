import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'package:emprendedor/features/client/controllers/index.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';
import 'package:emprendedor/features/nutritionist/controllers/index.dart';

final Logger _log = Logger('AuthLogoutService');

Future<void> signOutCurrentSession() async {
  // Inicia todo antes del primer await para que el logout anterior no pueda
  // alcanzar a una cuenta nueva y quitarle su token de notificaciones.
  final firebaseSignOut = FirebaseAuth.instance.signOut();
  final googleSignOut = GoogleSignIn().signOut();
  final deleteMessagingToken = FirebaseMessaging.instance.deleteToken();

  await Future.wait([firebaseSignOut, googleSignOut, deleteMessagingToken]);
}

/// Cierra sesión de forma segura:
/// 1. Resetea todos los controllers de todos los roles.
/// 2. Desconecta Google Sign-In si aplica.
/// 3. Cierra sesión en Firebase.
///
/// Llamar desde cualquier pantalla con acceso al BuildContext.
Future<void> performLogout(BuildContext context) async {
  // Capturar referencias antes de operaciones async.
  final productController = context.read<ProductController>();
  final orderController = context.read<OrderController>();
  final promotionController = context.read<PromotionController>();
  final statsController = context.read<StatsController>();
  final profileController = context.read<ProfileController>();
  final paymentMethodController = context.read<PaymentMethodController>();
  final socialMediaController = context.read<SocialMediaController>();
  final clientOrderController = context.read<ClientOrderController>();
  final appointmentController = context.read<AppointmentController>();
  final nutriAppController = context.read<NutritionistAppointmentsController>();

  try {
    // Primero cerrar la sesión real para que la navegación/auth cambie
    // inmediatamente. Después limpiar controllers en segundo plano visual.
    await signOutCurrentSession();

    await Future.wait([
      productController.reset(),
      orderController.reset(),
      promotionController.reset(),
      statsController.reset(),
      profileController.reset(),
      socialMediaController.setUserId(null),
      clientOrderController.setUserId(null),
      appointmentController.reset(),
      nutriAppController.setNutritionistUserId(null),
      paymentMethodController.reset(),
    ]);

    _log.info('Logout completado correctamente');
  } on Exception catch (e, st) {
    _log.severe('Error durante logout - forzando signOut de Firebase', e, st);
    // Garantizar siempre el cierre de sesión de Firebase.
    try {
      await FirebaseAuth.instance.signOut();
    } catch (authError, ast) {
      _log.severe('Error crítico cerrando FirebaseAuth', authError, ast);
    }
  }
}
