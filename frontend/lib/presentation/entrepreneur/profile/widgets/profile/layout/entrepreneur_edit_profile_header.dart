import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/entrepreneur/profile/widgets/index.dart';

class BusinessEditProfileHeader extends StatelessWidget {
  final File? selectedImageFile;
  final String? currentImageUrl;
  final bool isUploadingImage;
  final VoidCallback? onPickImage;

  const BusinessEditProfileHeader({
    super.key,
    required this.selectedImageFile,
    required this.currentImageUrl,
    required this.isUploadingImage,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: RoleTheme.brandBadgeBackground,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: RoleTheme.brandSoft),
      ),
      child: Row(
        children: [
          BusinessProfileImagePicker(
            selectedImageFile: selectedImageFile,
            currentImageUrl: currentImageUrl,
            isUploadingImage: isUploadingImage,
            onTap: onPickImage,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Presenta mejor tu negocio',
                  style: TextStyle(
                    color: RoleTheme.brandText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (isUploadingImage) ...[
                  SizedBox(height: 5.h),
                  Text(
                    'Subiendo logo, espera un momento...',
                    style: TextStyle(
                      color: RoleTheme.brandMutedText,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}








