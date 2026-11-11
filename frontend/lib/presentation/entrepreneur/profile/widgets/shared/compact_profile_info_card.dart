import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/entrepreneur/profile/widgets/index.dart';

class CompactProfileInfoCard extends StatelessWidget {
  final String? description;
  final String? address;
  final String? phone;
  final String? openingHours;

  const CompactProfileInfoCard({
    super.key,
    required this.description,
    required this.address,
    required this.phone,
    required this.openingHours,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 16.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        children: [
          CompactInfoRow(
            icon: Icons.info_outline_rounded,
            title: 'Descripción',
            content: description,
          ),
          Divider(height: 16.h, color: palette.primary.withValues(alpha: 0.10)),
          CompactInfoRow(
            icon: Icons.location_on_outlined,
            title: 'Dirección',
            content: address,
          ),
          Divider(height: 16.h, color: palette.primary.withValues(alpha: 0.10)),
          CompactInfoRow(
            icon: Icons.phone_rounded,
            title: 'teléfono',
            content: phone,
          ),
          Divider(height: 16.h, color: palette.primary.withValues(alpha: 0.10)),
          CompactInfoRow(
            icon: Icons.schedule_rounded,
            title: 'Horarios',
            content: openingHours,
          ),
        ],
      ),
    );
  }
}








