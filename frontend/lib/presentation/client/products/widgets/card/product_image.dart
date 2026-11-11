import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const ProductImage({super.key, this.imageUrl, this.size = 92});

  @override
  Widget build(BuildContext context) {
    final imageSize = size.w;

    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _placeholder(imageSize);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
        placeholder: (context, url) => _loadingPlaceholder(imageSize),
        errorWidget: (context, url, error) => _placeholder(imageSize),
      ),
    );
  }

  Widget _loadingPlaceholder(double imageSize) {
    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [RoleTheme.brandSurface, RoleTheme.brandSurfaceTint],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: RoleTheme.brandBorder),
      ),
    );
  }

  Widget _placeholder(double imageSize) {
    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        color: RoleTheme.brandSurfaceTint,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: RoleTheme.brandBorder),
      ),
      child: Icon(
        Icons.restaurant_menu_rounded,
        size: imageSize * 0.36,
        color: RoleTheme.iconHealth,
      ),
    );
  }
}
