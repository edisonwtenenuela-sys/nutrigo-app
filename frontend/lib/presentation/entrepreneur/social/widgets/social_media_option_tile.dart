import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/social_media_model.dart';

class SocialMediaOptionTile extends StatelessWidget {
  final SocialMediaType type;
  final Widget leading;
  final VoidCallback onTap;

  const SocialMediaOptionTile({
    super.key,
    required this.type,
    required this.leading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Ink(
          padding: EdgeInsets.all(13.w),
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: palette.primary.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: IconTheme(
                  data: IconThemeData(
                    color: palette.primary,
                    size: 22.sp,
                  ),
                  child: Center(child: leading),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  type.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: palette.primary,
                size: 15.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}