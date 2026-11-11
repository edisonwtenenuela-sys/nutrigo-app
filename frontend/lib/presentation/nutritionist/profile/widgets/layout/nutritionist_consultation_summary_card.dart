import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';

class NutritionistConsultationSummaryCard extends StatelessWidget {
  final NutritionistProfileModel? profile;
  final bool isVerified;

  const NutritionistConsultationSummaryCard({
    super.key,
    required this.profile,
    required this.isVerified,
  });

  String? _consultationPriceLabel() {
    if (profile?.consultationPrice == null) {
      return null;
    }

    return '\$${profile!.consultationPrice!.toStringAsFixed(2)}';
  }

  String? _consultationModeLabel() {
    switch (profile?.consultationMode) {
      case NutritionistConsultationMode.ambos:
        return 'Virtual\nPresencial';

      case NutritionistConsultationMode.presencial:
      case NutritionistConsultationMode.virtual:
        return profile?.consultationMode.label;

      case null:
        return null;
    }
  }

  String _statusLabel() => isVerified ? 'Activo' : 'Pendiente';

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 12.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryPill(
              icon: Icons.video_call_outlined,
              title: 'Modalidad',
              value: _consultationModeLabel(),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _SummaryPill(
              icon: Icons.attach_money_rounded,
              title: 'Consulta',
              value: _consultationPriceLabel(),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _SummaryPill(
              icon: isVerified
                  ? Icons.check_circle_rounded
                  : Icons.lock_clock_rounded,
              title: 'Estado',
              value: _statusLabel(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;

  const _SummaryPill({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    final hasValue = value != null && value!.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 19.sp,
            color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
          ),
          SizedBox(height: 6.h),
          Text(
            title,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 9.3.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            hasValue ? value!.trim() : 'Sin configurar',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: hasValue ? palette.text : RoleTheme.iconWarning,
              fontSize: 10.2.sp,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}
