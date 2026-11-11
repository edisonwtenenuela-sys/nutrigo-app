import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logging/logging.dart';
import 'package:emprendedor/app/app.dart';
import 'package:emprendedor/firebase_options.dart';

final Logger logger = Logger('AppLogger');
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Notificación en segundo plano: ${message.notification?.title}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  _setupLogging();
  await _initializeFirebase();
  await _initializeAppCheck();

  runApp(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const App(),
    ),
  );
}

void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint(
      '[${record.level.name}] ${record.time} [${record.loggerName}] ${record.message}',
    );
  });
}

Future<void> _initializeFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase inicializado correctamente.');
    }
  } catch (e, st) {
    logger.severe('Error inicializando Firebase', e, st);
    rethrow;
  }
}

Future<void> _initializeAppCheck() async {
  try {
    if (kDebugMode) {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: AndroidDebugProvider(),
        providerApple: AppleDebugProvider(),
      );
    } else {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: AndroidPlayIntegrityProvider(),
        providerApple: AppleAppAttestProvider(),
      );
    }
  } catch (e, st) {
    logger.warning('No se pudo inicializar App Check', e, st);
  }
}








