import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/social_media_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/social_link_launcher_controller.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class BusinessProfileSocialLinks extends StatelessWidget {
  final List<SocialMediaModel> socialMediaList;

  const BusinessProfileSocialLinks({
    super.key,
    required this.socialMediaList,
    this.linkLauncher = const SocialLinkLauncherController(),
  });

  final SocialLinkLauncherController linkLauncher;

  @override
  Widget build(BuildContext context) {
    final visibleLinks = socialMediaList
        .where((item) => item.url.trim().isNotEmpty)
        .take(5)
        .toList();

    if (visibleLinks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: RoleTheme.entrepreneur.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: RoleTheme.entrepreneur.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.w,
        runSpacing: 8.h,
        children: visibleLinks.map((item) {
          return InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () => _openUrl(context, item.url),
            child: Container(
              width: 39.w,
              height: 39.w,
              decoration: BoxDecoration(
                color: _backgroundColor(item.type),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Center(child: _ioon(item.type)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _ioon(SocialMediaType type) {
    switch (type) {
      case SocialMediaType.facebook:
        return FaIcon(
          FontAwesomeIcons.facebookF,
          size: 16.sp,
          color: const Color(0xFF1877F2),
        );
      case SocialMediaType.instagram:
        return FaIcon(
          FontAwesomeIcons.instagram,
          size: 17.sp,
          color: const Color(0xFFC13584),
        );
      case SocialMediaType.whatsapp:
        return FaIcon(
          FontAwesomeIcons.whatsapp,
          size: 17.sp,
          color: const Color(0xFF25D366),
        );
      case SocialMediaType.website:
        return Icon(
          Icons.language_rounded,
          size: 18.sp,
          color: RoleTheme.iconColorFor(
            Icons.language_rounded,
            fallback: RoleTheme.entrepreneur.primary,
          ),
        );
      case SocialMediaType.tiktok:
        return FaIcon(
          FontAwesomeIcons.tiktok,
          size: 16.sp,
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
        return RoleTheme.entrepreneur.primary.withValues(alpha: 0.08);
      case SocialMediaType.tiktok:
        return Colors.grey.shade100;
    }
  }

  Future<void> _openUrl(BuildContext context, String rawUrl) async {
    final opened = await linkLauncher.openSocialLink(rawUrl);
    if (opened || !context.mounted) return;

    showAppMessage(
      context,
      role: AppFeedbackRole.entrepreneur,
      type: AppFeedbackType.error,
      title: 'Enlaoe no disponible',
      message: 'No se pudo abrir el enlaoe.',
    );
  }
}










