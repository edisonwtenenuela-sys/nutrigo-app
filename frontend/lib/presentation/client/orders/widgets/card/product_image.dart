import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;

  const ProductImage({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    final size = 68.r;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: SizedBox(
        width: size,
        height: size,
        child: hasImage
            ? CachedNetworkImage(
          imageUrl: imageUrl!,
          fadeInDuration: const Duration(milliseconds: 120),
          memCacheWidth: 260,
          memCacheHeight: 260,
          imageBuilder: (context, imageProvider) => DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          placeholder: (context, url) => _placeholder(showIcon: false),
          errorWidget: (context, url, error) => _placeholder(),
        )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder({bool showIcon = true}) {
    return Container(
      color: RoleTheme.brandChipBackground,
      alignment: Alignment.center,
      child: showIcon
          ? Icon(
        Icons.restaurant_rounded,
        color: RoleTheme.iconColorFor(
          Icons.restaurant_rounded,
          fallback: RoleTheme.iconHealth,
        ),
        size: 28.sp,
      )
          : null,
    );
  }
}