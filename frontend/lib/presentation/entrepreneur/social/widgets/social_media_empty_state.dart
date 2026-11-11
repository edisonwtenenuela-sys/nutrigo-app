import 'package:flutter/material.dart';

import 'package:emprendedor/presentation/entrepreneur/shared/widgets/entrepreneur_empty_state.dart';

class SocialMediaEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const SocialMediaEmptyState({
    super.key,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return EntrepreneurEmptyState(
      icon: Icons.share_outlined,
      title: 'Sin redes sociales',
      subtitle:
      'Conecta tus redes sociales para que los clientes puedan seguirte y conocer más de tu negocio.',
      actionLabel: 'Agregar red social',
      onAction: onAdd,
    );
  }
}