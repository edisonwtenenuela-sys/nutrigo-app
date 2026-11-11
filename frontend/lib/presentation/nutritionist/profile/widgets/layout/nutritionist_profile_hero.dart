import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';
import 'package:emprendedor/presentation/shared/widgets/smooth_profile_avatar.dart';

class NutritionistProfileHero extends StatelessWidget {
  final NutritionistProfileModel? profile;
  final bool isVerified;
  final bool isUploadingImage;
  final VoidCallback onChangePhoto;

  const NutritionistProfileHero({
    super.key,
    required this.profile,
    required this.isVerified,
    required this.isUploadingImage,
    required this.onChangePhoto,
  });

  String _displayName() {
    final name = profile?.name.trim() ?? '';
    return name.isNotEmpty ? name : 'Perfil profesional';
  }

  String _displaySpecialty() {
    final specialty = profile?.specialty?.trim() ?? '';
    return specialty.isNotEmpty ? specialty : 'Especialidad no definida';
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    final name = _displayName();
    final specialty = _displaySpecialty();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(17.w),
      decoration: BoxDecoration(
        gradient: palette.headerGradient,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
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
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: palette.surface.withValues(alpha: 0.78),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(3.w),
                child: SmoothProfileAvatar(
                  imageUrl: profile?.profileImageUrl,
                  isLoading: isUploadingImage,
                  size: 62.r,
                  fallback: const _HeroFallbackIcon(),
                  overlayColor: Colors.black.withValues(alpha: 0.14),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: isUploadingImage ? null : onChangePhoto,
                  child: Container(
                    width: 27.w,
                    height: 27.w,
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(9.r),
                      border: Border.all(color: palette.primary, width: 1.3.w),
                    ),
                    child: isUploadingImage
                        ? Padding(
                            padding: EdgeInsets.all(6.w),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: palette.primary,
                            ),
                          )
                        : Icon(
                            Icons.camera_alt_rounded,
                            color: RoleTheme.iconColorFor(
                              Icons.camera_alt_rounded,
                              fallback: palette.primary,
                            ),
                            size: 14.sp,
                          ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.surface,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  specialty,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.surface.withValues(alpha: 0.86),
                    fontSize: 11.4.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 9.h),
                Wrap(
                  spacing: 7.w,
                  runSpacing: 6.h,
                  children: [
                    _HeroBadge(
                      icon: isVerified
                          ? Icons.verified_rounded
                          : Icons.pending_actions_rounded,
                      label: isVerified
                          ? 'Verificado'
                          : 'Pendiente de aprobación',
                    ),
                    const _HeroBadge(
                      icon: Icons.medical_services_rounded,
                      label: 'Nutricionista',
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

class _HeroFallbackIcon extends StatelessWidget {
  const _HeroFallbackIcon();

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Icon(
      Icons.health_and_safety_rounded,
      color: RoleTheme.iconColorFor(
        Icons.health_and_safety_rounded,
        fallback: palette.primary,
      ),
      size: 34.sp,
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
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
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
