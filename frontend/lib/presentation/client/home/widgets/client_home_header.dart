import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ClientHomeHeader extends StatelessWidget {
  final String displayName;
  final String? imageUrl;
  final String greeting;

  const ClientHomeHeader({
    super.key,
    required this.displayName,
    required this.imageUrl,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    final initials = displayName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: RoleTheme.brandBadgeBackground,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: RoleTheme.brandSoft.withValues(alpha: 0.72),
        ),
        boxShadow: [
          BoxShadow(
            color: RoleTheme.iconProfile.withValues(alpha: 0.07),
            blurRadius: 16.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 56.r,
              height: 56.r,
              color: Colors.white,
              child: hasImage
                  ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 450),
                fadeOutDuration: const Duration(milliseconds: 120),
                placeholder: (context, url) => const SizedBox.expand(),
                errorWidget: (context, url, error) =>
                    _InitialsAvatar(initials: initials),
              )
                  : _InitialsAvatar(initials: initials),
            ),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $displayName',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RoleTheme.brandText,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'Compra opciones validadas y agenda apoyo nutricional.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RoleTheme.brandMutedText,
                    fontSize: 11.5.sp,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 6.h,
                  children: const [
                    _HeaderChip(
                      icon: Icons.verified_rounded,
                      label: 'Validado',
                    ),
                    _HeaderChip(
                      icon: Icons.event_available_rounded,
                      label: 'Citas',
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

class _InitialsAvatar extends StatelessWidget {
  final String initials;

  const _InitialsAvatar({
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials.isEmpty ? 'C' : initials,
        style: TextStyle(
          color: RoleTheme.iconProfile,
          fontSize: 19.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = RoleTheme.iconColorFor(
      icon,
      fallback: RoleTheme.iconInfo,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: RoleTheme.brandSoft.withValues(alpha: 0.72),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 13.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color: iconColor,
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