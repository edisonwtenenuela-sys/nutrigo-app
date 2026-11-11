import 'package:flutter/material.dart';

import 'package:emprendedor/presentation/entrepreneur/shared/widgets/entrepreneur_empty_state.dart';

class OrdersEmptyState extends StatelessWidget {
  const OrdersEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EntrepreneurEmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'Aún no tienes pedidos recibidos',
      subtitle:
      'Cuando un cliente realice una compra, el pedido aparecerá aquí para que puedas gestionarlo.',
      infoIcon: Icons.notifications_active_rounded,
      infoText:
      'Mantendremos esta vista lista para que atiendas nuevos pedidos, cancelaciones y cambios de estado.',
    );
  }
}