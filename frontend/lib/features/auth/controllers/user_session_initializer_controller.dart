import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:emprendedor/core/services/auth/user_session_service.dart';
import 'package:emprendedor/features/client/controllers/index.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';
import 'package:emprendedor/features/nutritionist/controllers/nutritionist_appointments_controller.dart';

typedef UserSessionSyncHandler = Future<void> Function(String? userId);

class UserSessionInitializerController {
  UserSessionInitializerController({
    UserSessionService? sessionService,
    Stream<String?>? authUserIdStream,
  }) : _sessionService = sessionService,
       _authUserIdStream = authUserIdStream;

  final UserSessionService? _sessionService;
  final Stream<String?>? _authUserIdStream;
  StreamSubscription<String?>? _authSubscription;

  UserSessionService get _resolvedSessionService {
    return _sessionService ?? UserSessionService();
  }

  Stream<String?> authUserIdChanges() {
    return _authUserIdStream ?? _resolvedSessionService.authUserIdChanges();
  }

  void startListening({required UserSessionSyncHandler onUserChanged}) {
    _authSubscription?.cancel();
    _authSubscription = authUserIdChanges().listen((userId) async {
      try {
        await onUserChanged(userId);
      } catch (_) {}
    });
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    _authSubscription = null;
  }

  Future<void> syncControllers({
    required String? userId,
    required ProductController productController,
    required OrderController orderController,
    required StatsController statsController,
    required ProfileController profileController,
    required PromotionController promotionController,
    required PaymentMethodController paymentMethodController,
    required SocialMediaController socialMediaController,
    required ClientOrderController clientOrderController,
    required CartController cartController,
    required AppointmentController appointmentController,
    required NutritionistAppointmentsController
    nutritionistAppointmentsController,
  }) async {
    await _resetAllControllers(
      productController: productController,
      orderController: orderController,
      statsController: statsController,
      profileController: profileController,
      promotionController: promotionController,
      paymentMethodController: paymentMethodController,
      socialMediaController: socialMediaController,
      clientOrderController: clientOrderController,
      cartController: cartController,
      appointmentController: appointmentController,
      nutritionistAppointmentsController: nutritionistAppointmentsController,
    );

    if (userId == null) return;

    final sessionInfo = await _resolvedSessionService.loadSessionInfo(userId);
    final role = sessionInfo?.role;

    if (role == null || role.isEmpty) return;

    switch (role) {
      case 'cliente':
        await Future.wait([
          clientOrderController.setUserId(userId),
          appointmentController.loadNutritionists(),
          appointmentController.watchAppointmentsCount(),
          cartController.watchCart(),
        ]);
        break;
      case 'emprendedor':
        if (sessionInfo?.isVerified == true) {
          await Future.wait([
            productController.setUserId(userId),
            orderController.setBusinessUserId(userId),
            statsController.setUserId(userId),
            profileController.setUserId(userId),
            promotionController.setUserId(userId),
            socialMediaController.setUserId(userId),
            paymentMethodController.setUserId(userId),
          ]);
        } else {
          await Future.wait([
            profileController.setUserId(userId),
            socialMediaController.setUserId(userId),
            paymentMethodController.setUserId(userId),
          ]);
        }
        break;
      case 'nutricionista':
        await nutritionistAppointmentsController.setNutritionistUserId(userId);
        break;
      case 'pending_nutritionist':
        break;
      case 'admin':
        break;
      default:
        debugPrint('Rol no reconocido: $role');
    }
  }

  Future<void> _resetAllControllers({
    required ProductController productController,
    required OrderController orderController,
    required StatsController statsController,
    required ProfileController profileController,
    required PromotionController promotionController,
    required PaymentMethodController paymentMethodController,
    required SocialMediaController socialMediaController,
    required ClientOrderController clientOrderController,
    required CartController cartController,
    required AppointmentController appointmentController,
    required NutritionistAppointmentsController
    nutritionistAppointmentsController,
  }) {
    return Future.wait([
      productController.reset(),
      orderController.reset(),
      statsController.reset(),
      profileController.reset(),
      promotionController.reset(),
      paymentMethodController.reset(),
      socialMediaController.setUserId(null),
      clientOrderController.setUserId(null),
      cartController.reset(),
      appointmentController.reset(),
      nutritionistAppointmentsController.setNutritionistUserId(null),
    ]);
  }
}
