import 'package:flutter/material.dart';

import 'package:emprendedor/presentation/entrepreneur/shared/widgets/entrepreneur_empty_state.dart';

class PromotionEmptyState extends StatelessWidget {
  final VoidCallback onCreatePromotion;

  const PromotionEmptyState({
    super.key,
    required this.onCreatePromotion,
  });

  @override
  Widget build(BuildContext context) {
    return EntrepreneurEmptyState(
      icon: Icons.local_offer_outlined,
      title: 'Aún no tienes promociones',
      subtitle:
      'Crea descuentos para atraer clientes, mover productos y aumentar tus ventas dentro de la plataforma.',
      infoIcon: Icons.trending_up_rounded,
      infoText:
      'Las promociones activas podrán generar cupones para que tus clientes los apliquen en sus pedidos.',
      actionLabel: 'Crear promoción',
      onAction: onCreatePromotion,
    );
  }
}