import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/social_media_model.dart';
import 'package:emprendedor/presentation/entrepreneur/social/widgets/social_media_option_tile.dart';

class SocialMediaAddSheet extends StatelessWidget {
  final void Function(SocialMediaType type) onAdd;

  const SocialMediaAddSheet({
    super.key,
    required this.onAdd,
  });

  Widget _icon(SocialMediaType type) {
    const palette = RoleTheme.entrepreneur;

    switch (type) {
      case SocialMediaType.facebook:
        return FaIcon(
          FontAwesomeIcons.facebook,
          color: palette.primary,
          size: 22.sp,
        );

      case SocialMediaType.instagram:
        return FaIcon(
          FontAwesomeIcons.instagram,
          color: palette.primary,
          size: 22.sp,
        );

      case SocialMediaType.whatsapp:
        return FaIcon(
          FontAwesomeIcons.whatsapp,
          color: palette.primary,
          size: 22.sp,
        );

      case SocialMediaType.website:
        return Icon(
          Icons.public,
          color: RoleTheme.iconColorFor(
            Icons.public,
            fallback: palette.primary,
          ),
          size: 22.sp,
        );

      case SocialMediaType.tiktok:
        return FaIcon(
          FontAwesomeIcons.tiktok,
          color: palette.primary,
          size: 22.sp,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return SafeArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 24.h),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28.r),
          ),
          boxShadow: [
            BoxShadow(
              color: palette.primary.withValues(alpha: 0.08),
              blurRadius: 20.r,
              offset: Offset(0, -6.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
            SizedBox(height: 18.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: palette.primary.withValues(alpha: 0.10),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: palette.primary.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Icon(
                      Icons.share_rounded,
                      color: RoleTheme.iconColorFor(
                        Icons.share_rounded,
                        fallback: palette.primary,
                      ),
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Agregar red social',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.text,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Elige el canal que quieres mostrar en tu perfil.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.mutedText,
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            ...SocialMediaType.values.map((type) {
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: SocialMediaOptionTile(
                  type: type,
                  leading: _icon(type),
                  onTap: () {
                    Navigator.of(context).pop();
                    onAdd(type);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}