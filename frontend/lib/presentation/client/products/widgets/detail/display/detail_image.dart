import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class DetailImage extends StatelessWidget {
  final String? imageUrl;

  const DetailImage({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _placeholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        width: double.infinity,
        height: 190.h,
        decoration: BoxDecoration(
          color: RoleTheme.brandSurfaceTint,
          border: Border.all(color: RoleTheme.brandBorder),
        ),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          placeholder: (context, url) => _loadingPlaceholder(),
          errorWidget: (context, url, error) => _placeholder(),
        ),
      ),
    );
  }

  Widget _loadingPlaceholder() {
    return Container(color: RoleTheme.brandSurfaceTint);
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: 190.h,
      decoration: BoxDecoration(
        color: RoleTheme.brandSurfaceTint,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: RoleTheme.brandBorder),
      ),
      child: Icon(
        Icons.restaurant_menu_rounded,
        size: 46.sp,
        color: RoleTheme.iconHealth,
      ),
    );
  }
}
