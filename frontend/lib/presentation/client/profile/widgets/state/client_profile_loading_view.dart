import 'package:flutter/material.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/shared/widgets/registration_form_loading_view.dart';

class ClientProfileLoadingView extends StatelessWidget {
  const ClientProfileLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const RegistrationFormLoadingView(
      palette: RoleTheme.client,
      icon: Icons.person_rounded,
      eyebrow: 'PERFIL CLIENTE',
      title: 'Cargando perfil',
      message: 'Preparando tu información.',
      steps: [
        'Datos personales',
        'Información de contacto',
        'Preferencias',
      ],
    );
  }
}