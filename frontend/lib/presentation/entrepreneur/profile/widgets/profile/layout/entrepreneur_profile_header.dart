import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/business_profile_model.dart';

class BusinessProfileHeader extends StatelessWidget {
  final BusinessProfileModel profile;

  const BusinessProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;
    final imageUrl = profile.profileImageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18.r,
            offset: Offset(0, 9.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: RoleTheme.brandBadgeBackground,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: RoleTheme.brandSoft),
            ),
            child: Row(
              children: [
                Container(
                  width: 58.r,
                  height: 58.r,
                  decoration: BoxDecoration(
                    color: RoleTheme.brandSurface,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: RoleTheme.brandSoft),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: hasImage
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              _buildFallbackLogo(palette),
                          errorWidget: (context, url, error) =>
                              _buildFallbackLogo(palette),
                        )
                      : _buildFallbackLogo(palette),
                ),
                SizedBox(width: 13.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name.trim().isNotEmpty
                            ? profile.name.trim()
                            : 'Mi negocio',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: RoleTheme.brandText,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: const [
                          _HeaderBadge(
                            icon: Icons.store_mall_directory_rounded,
                            text: 'Negocio',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.055),
              borderRadius: BorderRadius.circular(17.r),
              border: Border.all(
                color: palette.primary.withValues(alpha: 0.10),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.tips_and_updates_rounded,
                  color: RoleTheme.iconColorFor(
                    Icons.tips_and_updates_rounded,
                    fallback: palette.primary,
                  ),
                  size: 20.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Mantén actualizada la información de tu negocio para generar confianza y tener mejor presentación ante los clientes.',
                    style: TextStyle(
                      color: palette.text,
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackLogo(RolePalette palette) {
    return Container(
      color: palette.surface,
      alignment: Alignment.center,
      child: Icon(
        Icons.storefront_rounded,
        size: 30.sp,
        color: RoleTheme.iconColorFor(
          Icons.storefront_rounded,
          fallback: palette.primary,
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeaderBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: RoleTheme.brandChipBackground,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: RoleTheme.iconColorFor(
              icon,
              fallback: RoleTheme.brandPrimary,
            ),
            size: 13.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              color: RoleTheme.brandPrimary,
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}








