import 'package:flutter/material.dart';

import 'package:emprendedor/presentation/entrepreneur/shared/widgets/entrepreneur_empty_state.dart';

class PaymentMethodEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const PaymentMethodEmptyState({
    super.key,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return EntrepreneurEmptyState(
      icon: Icons.credit_card_outlined,
      title: 'Sin métodos de pago',
      subtitle:
      'Agrega un método de pago para que tus clientes puedan realizar sus compras de forma segura.',
      actionLabel: 'Agregar método de pago',
      onAction: onAdd,
    );
  }
}