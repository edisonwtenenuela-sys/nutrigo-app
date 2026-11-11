import 'package:emprendedor/core/services/external_url_launcher_service.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/social_media_model.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BusinessSocialLinks extends StatelessWidget {
  final List<MapEntry<SocialMediaType, String>> links;
  final ExternalUrlLauncherService launcher;

  const BusinessSocialLinks({
    super.key,
    required this.links,
    required this.launcher,
  });

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: RoleTheme.client.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: RoleTheme.iconCommunication.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: links.map((entry) {
          return InkWell(
            borderRadius: BorderRadius.circular(13.r),
            onTap: () => _openUrl(context, entry.value),
            child: Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: _backgroundColor(entry.key),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(child: _icon(entry.key)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _icon(SocialMediaType type) {
    switch (type) {
      case SocialMediaType.facebook:
        return FaIcon(
          FontAwesomeIcons.facebookF,
          size: 14.sp,
          color: const Color(0xFF1877F2),
        );
      case SocialMediaType.instagram:
        return FaIcon(
          FontAwesomeIcons.instagram,
          size: 15.sp,
          color: const Color(0xFFC13584),
        );
      case SocialMediaType.whatsapp:
        return FaIcon(
          FontAwesomeIcons.whatsapp,
          size: 15.sp,
          color: const Color(0xFF25D366),
        );
      case SocialMediaType.website:
        return Icon(
          Icons.language_rounded,
          size: 16.sp,
          color: RoleTheme.iconColorFor(
            Icons.language_rounded,
            fallback: RoleTheme.iconCommunication,
          ),
        );
      case SocialMediaType.tiktok:
        return FaIcon(
          FontAwesomeIcons.tiktok,
          size: 14.sp,
          color: Colors.black87,
        );
    }
  }

  Color _backgroundColor(SocialMediaType type) {
    switch (type) {
      case SocialMediaType.facebook:
        return const Color(0xFFEAF3FF);
      case SocialMediaType.instagram:
        return const Color(0xFFFFEEF6);
      case SocialMediaType.whatsapp:
        return const Color(0xFFE9FFF1);
      case SocialMediaType.website:
        return RoleTheme.iconCommunication.withValues(alpha: 0.08);
      case SocialMediaType.tiktok:
        return RoleTheme.brandChipBackground;
    }
  }

  Future<void> _openUrl(BuildContext context, String rawUrl) async {
    final opened = await launcher.openExternalUrl(rawUrl);
    if (opened || !context.mounted) return;

    showAppMessage(
      context,
      role: AppFeedbackRole.client,
      type: AppFeedbackType.error,
      title: 'Enlace no disponible',
      message: 'No se pudo abrir la red social.',
    );
  }
}
