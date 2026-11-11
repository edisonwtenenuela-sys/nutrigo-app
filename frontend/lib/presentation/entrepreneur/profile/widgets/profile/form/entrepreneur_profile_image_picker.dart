import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/shared/widgets/smooth_profile_avatar.dart';

class BusinessProfileImagePicker extends StatelessWidget {
  final File? selectedImageFile;
  final String? currentImageUrl;
  final bool isUploadingImage;
  final VoidCallback? onTap;

  const BusinessProfileImagePicker({
    super.key,
    required this.selectedImageFile,
    required this.currentImageUrl,
    required this.isUploadingImage,
    required this.onTap,
  });

  bool get _showOverlay => isUploadingImage || selectedImageFile != null;

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return GestureDetector(
      onTap: isUploadingImage ? null : onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          SmoothProfileAvatar(
            imageUrl: currentImageUrl,
            isLoading: _showOverlay,
            size: 70.r,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(18.r),
            borderColor: Colors.white.withValues(alpha: 0.20),
            borderWidth: 1,
            overlayColor: Colors.black.withValues(alpha: 0.14),
            fallback: _fallbackIcon(palette),
          ),
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: palette.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.4.w),
            ),
            child: Icon(
              isUploadingImage
                  ? Icons.hourglass_top_rounded
                  : Icons.camera_alt_rounded,
              color: Colors.white,
              size: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackIcon(RolePalette palette) {
    return Container(
      color: palette.surface,
      alignment: Alignment.center,
      child: Icon(
        Icons.storefront_rounded,
        size: 25.sp,
        color: RoleTheme.iconColorFor(
          Icons.storefront_rounded,
          fallback: palette.primary,
        ),
      ),
    );
  }
}








