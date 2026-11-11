import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';

class AppNotificationService {
  AppNotificationService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
    FirebaseFunctions? functions,
    FlutterLocalNotificationsPlugin? localNotifications,
    Logger? logger,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _messaging = messaging ?? FirebaseMessaging.instance,
       _functions =
           functions ??
           FirebaseFunctions.instanceFor(region: 'southamerica-west1'),
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin(),
       _logger = logger ?? Logger('AppNotificationService');

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;
  final FirebaseFunctions _functions;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final Logger _logger;

  static const String _ordersChannelId = 'orders_channel';
  static const String _appointmentsChannelId = 'appointments_channel';
  static const String _adminChannelId = 'admin_channel';

  Future<void> initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(initializationSettings);

    const ordersChannel = AndroidNotificationChannel(
      _ordersChannelId,
      'Pedidos',
      description: 'Notificaciones de estados de pedidos',
      importance: Importance.high,
    );

    const appointmentsChannel = AndroidNotificationChannel(
      _appointmentsChannelId,
      'Citas',
      description: 'Notificaciones de agendamiento y estado de citas',
      importance: Importance.high,
    );

    const adminChannel = AndroidNotificationChannel(
      _adminChannelId,
      'Administración',
      description: 'Avisos de solicitudes pendientes para administradores',
      importance: Importance.high,
    );

    final androidNotifications = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidNotifications?.createNotificationChannel(ordersChannel);
    await androidNotifications?.createNotificationChannel(appointmentsChannel);
    await androidNotifications?.createNotificationChannel(adminChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> initializeForegroundNotifications() async {
    try {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
      final token = await _messaging.getToken();

      if (token != null) {
        await _saveFcmToken(token);
      }

      _messaging.onTokenRefresh.listen(_saveFcmToken);
      FirebaseMessaging.onMessage.listen(_showLocalNotification);
    } catch (error) {
      _logger.warning('No se pudieron inicializar las notificaciones: $error');
    }
  }

  StreamSubscription<User?> listenAuthAndSaveFcmToken() {
    return _auth.authStateChanges().listen((user) async {
      if (user == null) return;

      try {
        final token = await _messaging.getToken();

        if (token != null) {
          await _saveFcmToken(token);
        }
      } catch (error) {
        _logger.warning(
          'No se pudo obtener/guardar token FCM en authState: $error',
        );
      }
    });
  }

  Future<void> _saveFcmToken(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);

    try {
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        _logger.info(
          'FCM omitido: usuario sin perfil registrado (${user.uid})',
        );
        return;
      }

      final data = userDoc.data();
      final role = data?['role']?.toString().trim();

      if (role == null || role.isEmpty) {
        _logger.info('FCM omitido: usuario sin rol registrado (${user.uid})');
        return;
      }

      try {
        await _functions.httpsCallable('saveFcmTokenFromRequest').call({
          'token': token,
        });
      } on FirebaseFunctionsException catch (error) {
        _logger.warning(
          'No se pudo sincronizar FCM token con Functions (${error.code}).',
        );
        await userRef.update({
          'fcmToken': token,
          'fcmTokens': [token],
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseException catch (error) {
      _logger.warning('No se pudo guardar FCM token (${error.code}).');
    } catch (error) {
      _logger.warning('Error inesperado guardando FCM token: $error');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    if (!await _shouldShowMessageForCurrentUser(message)) return;

    final details = NotificationDetails(
      android: _androidNotificationDetailsFor(message),
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
    );
  }

  Future<bool> _shouldShowMessageForCurrentUser(RemoteMessage message) async {
    final targetUserId = message.data['targetUserId']?.toString().trim() ?? '';
    if (targetUserId.isEmpty) return true;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;
    if (targetUserId == currentUser.uid) return true;

    if (targetUserId == 'nutritionists') {
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
        final role = userDoc.data()?['role']?.toString().trim().toLowerCase();
        return role == 'nutricionista' || role == 'nutritionist';
      } catch (error) {
        _logger.warning(
          'No se pudo validar destinatario de notificación: $error',
        );
        return false;
      }
    }

    return false;
  }

  AndroidNotificationDetails _androidNotificationDetailsFor(
    RemoteMessage message,
  ) {
    if (_isAdminNotification(message)) {
      return const AndroidNotificationDetails(
        _adminChannelId,
        'Administración',
        icon: 'ic_notification',
        channelDescription:
            'Avisos de solicitudes pendientes para administradores',
        importance: Importance.high,
        priority: Priority.high,
      );
    }

    if (_isAppointmentNotification(message)) {
      return const AndroidNotificationDetails(
        _appointmentsChannelId,
        'Citas',
        icon: 'ic_notification',
        channelDescription: 'Notificaciones de agendamiento y estado de citas',
        importance: Importance.high,
        priority: Priority.high,
      );
    }

    return const AndroidNotificationDetails(
      _ordersChannelId,
      'Pedidos',
      icon: 'ic_notification',
      channelDescription: 'Notificaciones de estados de pedidos',
      importance: Importance.high,
      priority: Priority.high,
    );
  }

  bool _isAdminNotification(RemoteMessage message) {
    final type = message.data['type']?.toString() ?? '';
    return type == 'entrepreneur_verification_submitted' ||
        type == 'nutritionist_verification_submitted';
  }

  bool _isAppointmentNotification(RemoteMessage message) {
    final type = message.data['type']?.toString() ?? '';
    return type.startsWith('appointment_');
  }
}








