import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ProductImagePickerSection extends StatelessWidget {
  final bool isLoading;
  final String? selectedImagePath;
  final String? currentImageUrl;
  final VoidCallback onPickImage;

  const ProductImagePickerSection({
    super.key,
    required this.isLoading,
    required this.selectedImagePath,
    required this.currentImageUrl,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;
    final hasSelectedImage =
        selectedImagePath != null && selectedImagePath!.trim().isNotEmpty;
    final hasCurrentImage =
        currentImageUrl != null && currentImageUrl!.trim().isNotEmpty;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(17.r),
          child: SizedBox(
            width: double.infinity,
            height: 142.h,
            child: hasSelectedImage
                ? Image.file(File(selectedImagePath!), fit: BoxFit.contain)
                : hasCurrentImage
                ? CachedNetworkImage(
                    imageUrl: currentImageUrl!,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const SizedBox(),
                    errorWidget: (context, url, error) =>
                        const _ImagePlaceholder(),
                  )
                : const _ImagePlaceholder(),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity,
          height: 42.h,
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : onPickImage,
            icon: Icon(
              Icons.image_rounded,
              color: RoleTheme.iconColorFor(Icons.image_rounded),
              size: 17.sp,
            ),
            label: Text(
              hasSelectedImage
                  ? 'Imagen seleccionada'
                  : hasCurrentImage
                  ? 'Cambiar imagen'
                  : 'Seleccionar imagen',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.primary,
              backgroundColor: palette.primary.withValues(alpha: 0.055),
              side: BorderSide(color: palette.primary.withValues(alpha: 0.18)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      color: palette.primary.withValues(alpha: 0.07),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_rounded,
              color: RoleTheme.iconColorFor(
                Icons.add_photo_alternate_rounded,
                fallback: palette.primary,
              ),
              size: 38.sp,
            ),
            SizedBox(height: 7.h),
            Text(
              'Foto del producto',
              style: TextStyle(
                color: palette.text,
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Usa una imagen clara y real',
              style: TextStyle(
                color: palette.mutedText,
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}








