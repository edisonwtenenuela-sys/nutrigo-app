import 'package:flutter/material.dart';
import 'package:emprendedor/presentation/shared/widgets/buttons/app_action_button.dart';

class AppointmentPayButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onPressed;

  const AppointmentPayButton({
    super.key,
    required this.isSaving,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClientActionButton(
      label: 'Pagar y agendar cita',
      loadingLabel: 'Procesando...',
      icon: Icons.payment_rounded,
      isLoading: isSaving,
      onPressed: onPressed,
    );
  }
}