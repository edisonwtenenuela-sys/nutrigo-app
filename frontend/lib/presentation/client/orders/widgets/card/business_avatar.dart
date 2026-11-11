import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class BusinessAvatar extends StatelessWidget {
  final String? imageUrl;

  const BusinessAvatar({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    final size = 34.r;

    return ClipRRect(
      borderRadius: BorderRadius.circular(9.r),
      child: SizedBox.square(
        dimension: size,
        child: hasImage
            ? CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 120),
          memCacheWidth: 120,
          memCacheHeight: 120,
          placeholder: (context, url) => _placeholder(showIcon: false),
          errorWidget: (context, url, error) => _placeholder(),
        )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder({bool showIcon = true}) {
    return Container(
      color: RoleTheme.brandSurfaceTint.withValues(alpha: 0.30),
      alignment: Alignment.center,
      child: showIcon
          ? Icon(
        Icons.storefront_rounded,
        size: 17.sp,
        color: RoleTheme.iconColorFor(
          Icons.storefront_rounded,
          fallback: RoleTheme.iconInfo,
        ),
      )
          : null,
    );
  }
}