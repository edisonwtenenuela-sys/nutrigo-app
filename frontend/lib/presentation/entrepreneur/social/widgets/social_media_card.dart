import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/social_media_model.dart';

class SocialMediaCard extends StatelessWidget {
  final SocialMediaModel socialMedia;
  final Widget leading;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const SocialMediaCard({
    super.key,
    required this.socialMedia,
    required this.leading,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 16.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Center(child: leading),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  socialMedia.type.label,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w900,
                    color: palette.text,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  socialMedia.url.trim().isNotEmpty
                      ? socialMedia.url
                      : 'Anadir URL',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.8.sp,
                    color: palette.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          _MiniActionButton(
            icon: Icons.edit_rounded,
            color: palette.primary,
            onTap: onEdit,
          ),
          SizedBox(width: 7.w),
          _MiniActionButton(
            icon: Icons.delete_rounded,
            color: Colors.red,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _MiniActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(13.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13.r),
        child: SizedBox(
          width: 34.w,
          height: 34.w,
          child: Icon(icon, color: color, size: 18.sp),
        ),
      ),
    );
  }
}








