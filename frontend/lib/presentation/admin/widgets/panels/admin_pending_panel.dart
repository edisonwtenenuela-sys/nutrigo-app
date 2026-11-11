import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/admin/widgets/index.dart';

class AdminPendingPanel extends StatelessWidget {
  final VoidCallback onEntrepreneurs;
  final VoidCallback onNutritionists;

  const AdminPendingPanel({
    super.key,
    required this.onEntrepreneurs,
    required this.onNutritionists,
  });

  Widget _buildAction({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AdminActionCard(
      icon: icon,
      iconColor: iconColor,
      iconBackground: iconBackground,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.admin;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminSectionTitle(
          icon: Icons.assignment_turned_in_rounded,
          title: 'Panel de aprobaciones',
          subtitle: 'Selecciona el tipo de solicitud a revisar.',
        ),
        SizedBox(height: 12.h),
        _buildAction(
          icon: Icons.storefront_rounded,
          iconColor: palette.primary,
          iconBackground: palette.primary.withValues(alpha: 0.10),
          title: 'Emprendedores',
          subtitle: 'Verifica negocios antes de habilitar su operación.',
          onTap: onEntrepreneurs,
        ),
        SizedBox(height: 12.h),
        _buildAction(
          icon: Icons.health_and_safety_rounded,
          iconColor: RoleTheme.iconHealth,
          iconBackground: RoleTheme.iconHealth.withValues(alpha: 0.12),
          title: 'Nutricionistas',
          subtitle: 'Valida profesionales para revisión nutricional.',
          onTap: onNutritionists,
        ),
      ],
    );
  }
}