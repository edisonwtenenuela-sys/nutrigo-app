import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class ProductItemImage extends StatelessWidget {
  final String? imageUrl;

  const ProductItemImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    if (!hasImage) return _placeholder();

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      child: SizedBox(
        height: 88.h,
        width: double.infinity,
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
          placeholder: (context, url) => const SizedBox(),
          errorWidget: (context, url, error) => _placeholder(),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 88.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: RoleTheme.brandChipBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Icon(
        Icons.fastfood_rounded,
        size: 34.sp,
        color: RoleTheme.iconHealth,
      ),
    );
  }
}








