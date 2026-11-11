import 'package:flutter/material.dart';

import 'package:emprendedor/presentation/entrepreneur/shared/widgets/entrepreneur_empty_state.dart';

class StatisticsEmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const StatisticsEmptyState({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return EntrepreneurEmptyState(
      icon: Icons.bar_chart_outlined,
      title: 'Sin estadísticas aún',
      subtitle:
      'Las métricas de ventas, pedidos e ingresos aparecerán aquí cuando tengas actividad registrada.',
      infoIcon: Icons.info_outline_rounded,
      infoText:
      'Las estadísticas se actualizarán a medida que recibas y gestiones nuevos pedidos.',
      actionLabel: 'Actualizar',
      onAction: onRefresh,
    );
  }
}