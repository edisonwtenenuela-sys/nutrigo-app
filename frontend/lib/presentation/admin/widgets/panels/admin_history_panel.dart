import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/admin/widgets/index.dart';

class AdminHistoryPanel extends StatelessWidget {
  final VoidCallback onApproved;
  final VoidCallback onRejected;

  const AdminHistoryPanel({
    super.key,
    required this.onApproved,
    required this.onRejected,
  });

  Widget _buildHistoryCard({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminSectionTitle(
          icon: Icons.manage_search_rounded,
          title: 'Panel de historial',
          subtitle: 'Consulta solicitudes aprobadas o rechazadas.',
        ),
        SizedBox(height: 12.h),
        _buildHistoryCard(
          icon: Icons.check_circle_rounded,
          iconColor: RoleTheme.iconValidation,
          iconBackground: RoleTheme.iconValidation.withValues(alpha: 0.11),
          title: 'Aprobadas',
          subtitle: 'Revisa usuarios aceptados por administración.',
          onTap: onApproved,
        ),
        SizedBox(height: 12.h),
        _buildHistoryCard(
          icon: Icons.cancel_rounded,
          iconColor: RoleTheme.iconDanger,
          iconBackground: RoleTheme.iconDanger.withValues(alpha: 0.10),
          title: 'Rechazadas',
          subtitle: 'Consulta solicitudes rechazadas anteriormente.',
          onTap: onRejected,
        ),
      ],
    );
  }
}