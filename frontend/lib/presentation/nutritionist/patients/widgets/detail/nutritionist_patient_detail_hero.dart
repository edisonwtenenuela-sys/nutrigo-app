import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistPatientDetailHero extends StatelessWidget {
  final String name;
  final String initial;
  final String? imageUrl;
  final String statusText;

  const NutritionistPatientDetailHero({
    super.key,
    required this.name,
    required this.initial,
    required this.imageUrl,
    required this.statusText,
  });

  Widget _buildStatusChip() {
    const palette = RoleTheme.nutritionist;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            color: RoleTheme.iconColorFor(
              Icons.verified_rounded,
              fallback: palette.primary,
            ),
            size: 13.sp,
          ),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              statusText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.primary,
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: palette.headerGradient,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 22.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Row(
        children: [
          _HeroAvatar(initial: initial, imageUrl: imageUrl),
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
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                  ),
                ),
                SizedBox(height: 9.h),
                _buildStatusChip(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroAvatar extends StatelessWidget {
  final String initial;
  final String? imageUrl;

  const _HeroAvatar({
    required this.initial,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: 74.w,
      height: 74.w,
      decoration: BoxDecoration(
        color: palette.surface,
        shape: BoxShape.circle,
        border: Border.all(color: palette.primary.withValues(alpha: 0.12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? CachedNetworkImage(
        imageUrl: imageUrl!.trim(),
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 320),
        fadeOutDuration: Duration.zero,
        placeholder: (_, _) => const SizedBox.expand(),
        errorWidget: (_, _, _) => _HeroInitial(initial: initial),
      )
          : _HeroInitial(initial: initial),
    );
  }
}

class _HeroInitial extends StatelessWidget {
  final String initial;

  const _HeroInitial({required this.initial});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: palette.primary,
          fontSize: 28.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}