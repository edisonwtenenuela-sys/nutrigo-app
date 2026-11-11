import 'package:flutter/material.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/shared/widgets/registration_form_loading_view.dart';

class ClientProfileEditLoadingView extends StatelessWidget {
  const ClientProfileEditLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const RegistrationFormLoadingView(
      palette: RoleTheme.client,
      icon: Icons.person_search_rounded,
      eyebrow: 'PERFIL CLIENTE',
      title: 'Cargando perfil',
      message: 'Preparando tus datos para edición.',
      steps: ['Datos personales', 'Entrega', 'Salud'],
    );
  }
}