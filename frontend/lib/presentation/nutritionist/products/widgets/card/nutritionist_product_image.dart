import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistProductImage extends StatelessWidget {
  final String? imageUrl;

  const NutritionistProductImage({
    super.key,
    required this.imageUrl,
  });

  bool _hasImage() {
    return imageUrl != null && imageUrl!.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;
    final hasImage = _hasImage();

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      child: SizedBox(
        width: double.infinity,
        height: 125.h,
        child: hasImage
            ? CachedNetworkImage(
          imageUrl: imageUrl!.trim(),
          fit: BoxFit.contain,
          fadeInDuration: const Duration(milliseconds: 300),
          fadeOutDuration: const Duration(milliseconds: 120),
          placeholder: (_, _) => _ImageLoadingState(palette: palette),
          errorWidget: (_, _, _) => const _ImagePlaceholder(),
        )
            : const _ImagePlaceholder(),
      ),
    );
  }
}

class _ImageLoadingState extends StatelessWidget {
  final RolePalette palette;

  const _ImageLoadingState({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: palette.background,
      alignment: Alignment.center,
      child: SizedBox(
        width: 22.w,
        height: 22.w,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: palette.primary,
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      width: double.infinity,
      height: 125.h,
      decoration: BoxDecoration(
        gradient: palette.headerGradient,
      ),
      child: Center(
        child: Icon(
          Icons.fastfood_rounded,
          size: 46.sp,
          color: palette.surface,
        ),
      ),
    );
  }
}