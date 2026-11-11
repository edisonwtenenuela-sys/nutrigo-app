import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:emprendedor/features/auth/controllers/user_session_initializer_controller.dart';
import 'package:emprendedor/features/client/controllers/index.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';
import 'package:emprendedor/features/nutritionist/controllers/nutritionist_appointments_controller.dart';

class UserSessionInitializer extends StatefulWidget {
  final Widget child;

  const UserSessionInitializer({super.key, required this.child});

  @override
  State<UserSessionInitializer> createState() => _UserSessionInitializerState();
}

class _UserSessionInitializerState extends State<UserSessionInitializer> {
  final UserSessionInitializerController _controller =
      UserSessionInitializerController();
  Future<void> _syncControllers(String? userId) {
    return _controller.syncControllers(
      userId: userId,
      productController: context.read<ProductController>(),
      orderController: context.read<OrderController>(),
      statsController: context.read<StatsController>(),
      profileController: context.read<ProfileController>(),
      promotionController: context.read<PromotionController>(),
      paymentMethodController: context.read<PaymentMethodController>(),
      socialMediaController: context.read<SocialMediaController>(),
      clientOrderController: context.read<ClientOrderController>(),
      cartController: context.read<CartController>(),
      appointmentController: context.read<AppointmentController>(),
      nutritionistAppointmentsController: context
          .read<NutritionistAppointmentsController>(),
    );
  }

  @override
  void initState() {
    super.initState();

    _controller.startListening(
      onUserChanged: (userId) async {
        if (!mounted) return;
        await _syncControllers(userId);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}








