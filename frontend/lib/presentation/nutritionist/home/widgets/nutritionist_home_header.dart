import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistHomeHeader extends StatelessWidget {
  final String name;
  final String specialty;
  final String? imageUrl;

  const NutritionistHomeHeader({
    super.key,
    required this.name,
    required this.specialty,
    required this.imageUrl,
  });

  static const String _patientsLabel = 'Pacientes';
  static const String _validationsLabel = 'Validaciones';

  String get _displayName {
    final trimmed = name.trim();
    return trimmed.isNotEmpty ? trimmed : 'Profesional';
  }

  String get _displaySpecialty {
    final trimmed = specialty.trim();
    return trimmed.isNotEmpty ? trimmed : 'Especialidad no definida';
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 17.h),
      decoration: BoxDecoration(
        gradient: palette.headerGradient,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 64.r,
              height: 64.r,
              color: palette.surface.withValues(alpha: 0.86),
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!.trim(),
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 450),
                      fadeOutDuration: const Duration(milliseconds: 120),
                      placeholder: (_, _) => const _HeaderImageLoader(),
                      errorWidget: (_, _, _) => const _HeaderFallbackIcon(),
                    )
                  : const _HeaderFallbackIcon(),
            ),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, $_displayName',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.surface,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  _displaySpecialty,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.surface.withValues(alpha: 0.86),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                const Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _ProfessionalChip(
                      icon: Icons.groups_rounded,
                      label: _patientsLabel,
                    ),
                    _ProfessionalChip(
                      icon: Icons.verified_rounded,
                      label: _validationsLabel,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderFallbackIcon extends StatelessWidget {
  const _HeaderFallbackIcon();

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Center(
      child: Icon(
        Icons.health_and_safety_rounded,
        color: RoleTheme.iconColorFor(
          Icons.health_and_safety_rounded,
          fallback: palette.primary,
        ),
        size: 32.sp,
      ),
    );
  }
}

class _HeaderImageLoader extends StatelessWidget {
  const _HeaderImageLoader();

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Center(
      child: SizedBox(
        width: 20.r,
        height: 20.r,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: palette.primary,
          backgroundColor: palette.primary.withValues(alpha: 0.14),
        ),
      ),
    );
  }
}

class _ProfessionalChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProfessionalChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
            size: 13.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color: palette.primary,
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
