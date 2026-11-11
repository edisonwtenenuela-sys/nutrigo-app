import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/app/providers/app_providers.dart';
import 'package:emprendedor/core/services/app_notification_service.dart';
import 'package:emprendedor/core/theme/app_theme.dart';
import 'package:emprendedor/presentation/auth/pages/auth_wrapper.dart';
import 'package:emprendedor/presentation/shared/widgets/app_launch_splash.dart';
import 'package:emprendedor/presentation/shared/widgets/responsive_app_frame.dart';
import 'package:emprendedor/presentation/shared/widgets/user_session_initializer.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final AppNotificationService _notificationService = AppNotificationService();
  StreamSubscription<User?>? _authFcmSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _notificationService.initializeLocalNotifications();
      await _notificationService.initializeForegroundNotifications();
      _authFcmSubscription = _notificationService.listenAuthAndSaveFcmToken();
    });
  }

  @override
  void dispose() {
    _authFcmSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: MaterialApp(
        title: 'NutriGo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(),
        locale: const Locale('es', 'ES'),
        supportedLocales: const [Locale('es', 'ES')],
        builder: (context, child) =>
            ResponsiveAppFrame(child: child ?? const SizedBox.shrink()),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const AppLaunchSplash(
          child: UserSessionInitializer(child: AuthWrapper()),
        ),
      ),
    );
  }
}








