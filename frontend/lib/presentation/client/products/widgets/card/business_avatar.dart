import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class BusinessAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const BusinessAvatar({super.key, required this.imageUrl, this.size = 22});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(7.r),
      child: SizedBox(
        width: size.r,
        height: size.r,
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.contain,
                placeholder: (context, url) => _placeholder(),
                errorWidget: (context, url, error) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return DecoratedBox(
      decoration: const BoxDecoration(color: RoleTheme.brandChipBackground),
      child: Icon(
        Icons.storefront_rounded,
        size: 13.sp,
        color: RoleTheme.iconInfo,
      ),
    );
  }
}
