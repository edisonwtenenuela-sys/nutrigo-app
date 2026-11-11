import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ReviewCommentField extends StatelessWidget {
  final TextEditingController controller;

  const ReviewCommentField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return TextField(
      controller: controller,
      maxLines: 3,
      style: TextStyle(
        color: palette.text,
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: 'Escribe un comentario opcional...',
        hintStyle: TextStyle(
          color: palette.mutedText,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: palette.background,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 12.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(
            color: RoleTheme.iconRating.withValues(alpha: 0.12),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(
            color: RoleTheme.iconRating.withValues(alpha: 0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(
            color: RoleTheme.iconRating,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}