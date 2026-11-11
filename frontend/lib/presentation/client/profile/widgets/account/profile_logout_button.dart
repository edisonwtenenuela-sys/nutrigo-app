import 'package:flutter/material.dart';

import 'package:emprendedor/presentation/shared/widgets/buttons/app_action_button.dart';

class ProfileLogoutButton extends StatelessWidget {
  static const Color _logoutColor = Color(0xFFDC2626);

  final VoidCallback onPressed;

  const ProfileLogoutButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClientActionButton(
      label: 'Cerrar sesión',
      icon: Icons.logout_rounded,
      color: _logoutColor,
      onPressed: onPressed,
    );
  }
}