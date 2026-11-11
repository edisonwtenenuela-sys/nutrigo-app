import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/business_profile_model.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/social_media_model.dart';
import 'package:emprendedor/data/models/shared/order_business_summary.dart';
import 'package:emprendedor/core/services/external_url_launcher_service.dart';
import 'package:emprendedor/data/repositories/entrepreneur/profile/business_profile_repository.dart';
import 'package:emprendedor/data/repositories/entrepreneur/profile/social_media_repository.dart';
import 'package:emprendedor/data/repositories/shared/order_repository.dart';
import 'package:emprendedor/presentation/client/products/widgets/business_store/business_logo.dart';
import 'package:emprendedor/presentation/client/products/widgets/business_store/header_pill.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BusinessStoreHeader extends StatelessWidget {
  final OrderBusinessSummary summary;
  final String businessId;
  final List<ProductModel> products;
  final BusinessProfileModel? profile;
  final String Function(String name) visibleBusinessName;
  final List<String> Function(String openingHours) openingHourChips;
  final String Function(OrderBusinessSummary summary) reviewsText;
  final List<MapEntry<SocialMediaType, String>> socialLinks;
  final ExternalUrlLauncherService launcher;

  const BusinessStoreHeader({
    super.key,
    required this.summary,
    required this.businessId,
    required this.products,
    required this.profile,
    required this.visibleBusinessName,
    required this.openingHourChips,
    required this.reviewsText,
    this.socialLinks = const [],
    this.launcher = const ExternalUrlLauncherService(),
  });

  @override
  Widget build(BuildContext context) {
    final businessName = visibleBusinessName(summary.name);
    final profileOpeningHours = profile?.openingHours?.trim() ?? '';
    final openingHours = profileOpeningHours.isNotEmpty
        ? profileOpeningHours
        : summary.openingHours?.trim() ?? '';
    final hourChips = openingHourChips(openingHours);
    final description = _descriptionText(profile, summary);
    final headerTagline = _headerTagline(description);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE6EDFA), RoleTheme.brandBadgeBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: RoleTheme.brandSoft),
        boxShadow: [
          BoxShadow(
            color: RoleTheme.iconHealth.withValues(alpha: 0.12),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 3.h),
                child: BusinessLogo(imageUrl: summary.imageUrl),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: RoleTheme.brandText,
                        fontSize: 19.sp,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      headerTagline,
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        color: RoleTheme.brandMutedText,
                        fontSize: 11.sp,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 7.w,
            runSpacing: 6.h,
            children: [
              const HeaderPill(
                icon: Icons.verified_rounded,
                label: 'Negocio verificado',
              ),
              HeaderPill(
                icon: summary.totalReviews > 0
                    ? Icons.star_rounded
                    : Icons.rate_review_rounded,
                label: reviewsText(summary),
              ),
              _DetailsButton(
                onTap: () => _showDetailsSheet(
                  context,
                  businessName: businessName,
                  description: description,
                  openingHours: openingHours,
                  hourChips: hourChips,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _descriptionText(
    BusinessProfileModel? profile,
    OrderBusinessSummary summary,
  ) {
    final description = profile?.description?.trim();
    if (description != null && description.isNotEmpty) return description;
    final summaryDescription = summary.description?.trim();
    if (summaryDescription != null && summaryDescription.isNotEmpty) {
      return summaryDescription;
    }
    return 'Explora productos saludables validados por un nutricionista.';
  }

  String _headerTagline(String description) {
    final normalized = description.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      return 'Productos frescos y saludables para tu día.';
    }

    final lower = normalized.toLowerCase();
    if (lower.contains('salud')) {
      return 'Productos frescos y saludables para tu día.';
    }
    if (lower.contains('postre') || lower.contains('dulce')) {
      return 'Opciones dulces preparadas con cuidado.';
    }
    if (lower.contains('prote') || lower.contains('energ')) {
      return 'Opciones nutritivas para acompañar tu rutina.';
    }

    return 'Comidas preparadas con calidad y cuidado.';
  }

  void _showDetailsSheet(
    BuildContext context, {
    required String businessName,
    required String description,
    required String openingHours,
    required List<String> hourChips,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _BusinessStoreDetailsSheet(
          businessName: businessName,
          businessId: businessId,
          description: description,
          summary: summary,
          profile: profile,
          productsCount: products.length,
          openingHours: openingHours,
          hourChips: hourChips,
          address: profile?.address?.trim(),
          phone: profile?.phone?.trim(),
          socialLinks: socialLinks,
          launcher: launcher,
        );
      },
    );
  }
}

class _DetailsButton extends StatelessWidget {
  const _DetailsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: RoleTheme.brandSurface,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: RoleTheme.brandSoft),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: RoleTheme.iconInfo,
              size: 13.sp,
            ),
            SizedBox(width: 4.w),
            Text(
              'Ver detalles',
              style: TextStyle(
                color: RoleTheme.brandPrimary,
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessStoreDetailsSheet extends StatelessWidget {
  const _BusinessStoreDetailsSheet({
    required this.businessName,
    required this.businessId,
    required this.description,
    required this.summary,
    required this.profile,
    required this.productsCount,
    required this.openingHours,
    required this.hourChips,
    required this.address,
    required this.phone,
    required this.socialLinks,
    required this.launcher,
  });

  final String businessName;
  final String businessId;
  final String description;
  final OrderBusinessSummary summary;
  final BusinessProfileModel? profile;
  final int productsCount;
  final String openingHours;
  final List<String> hourChips;
  final String? address;
  final String? phone;
  final List<MapEntry<SocialMediaType, String>> socialLinks;
  final ExternalUrlLauncherService launcher;

  static final OrderRepository _orderRepository = OrderRepository();
  static final BusinessProfileRepository _profileRepository =
      BusinessProfileRepository();
  static final SocialMediaRepository _socialMediaRepository =
      SocialMediaRepository();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OrderBusinessSummary>(
      stream: _orderRepository.watchBusinessSummaryForOrder(businessId),
      initialData: summary,
      builder: (context, summarySnapshot) {
        final liveSummary = summarySnapshot.data ?? summary;

        return StreamBuilder<BusinessProfileModel?>(
          stream: _profileRepository.watchBusinessProfile(businessId),
          initialData: profile,
          builder: (context, profileSnapshot) {
            final liveProfile = profileSnapshot.data ?? profile;

            return StreamBuilder<List<SocialMediaModel>>(
              stream: _socialMediaRepository.getSocialMediaLinks(businessId),
              builder: (context, socialSnapshot) {
                final liveSocialLinks = _mergeSocialLinks(
                  profile: liveProfile,
                  socialMediaLinks:
                      socialSnapshot.data ?? const <SocialMediaModel>[],
                  fallback: socialLinks,
                );
                final liveDescription = _resolveDescription(
                  liveProfile,
                  liveSummary,
                  description,
                );
                final liveOpeningHours =
                    liveProfile?.openingHours?.trim().isNotEmpty == true
                    ? liveProfile!.openingHours!.trim()
                    : liveSummary.openingHours?.trim() ?? openingHours;

                return _BusinessStoreDetailsSheetBody(
                  businessName: businessName,
                  description: liveDescription,
                  productsCount: productsCount,
                  openingHours: liveOpeningHours,
                  hourChips: _splitOpeningHours(liveOpeningHours, hourChips),
                  address: liveProfile?.address?.trim() ?? address,
                  phone: liveProfile?.phone?.trim() ?? phone,
                  socialLinks: liveSocialLinks,
                  launcher: launcher,
                );
              },
            );
          },
        );
      },
    );
  }

  List<MapEntry<SocialMediaType, String>> _mergeSocialLinks({
    required BusinessProfileModel? profile,
    required List<SocialMediaModel> socialMediaLinks,
    required List<MapEntry<SocialMediaType, String>> fallback,
  }) {
    final links = <SocialMediaType, String>{
      for (final entry in fallback) entry.key: entry.value,
    };

    for (final entry
        in profile?.socialMediaLinks.entries ??
            const Iterable<MapEntry<String, String>>.empty()) {
      final value = entry.value.trim();
      if (value.isEmpty) continue;
      links[stringToSocialMediaType(entry.key)] = value;
    }

    for (final link in socialMediaLinks) {
      final value = link.url.trim();
      if (value.isEmpty) continue;
      links[link.type] = value;
    }

    return links.entries.toList();
  }

  String _resolveDescription(
    BusinessProfileModel? profile,
    OrderBusinessSummary summary,
    String fallback,
  ) {
    final profileDescription = profile?.description?.trim();
    if (profileDescription != null && profileDescription.isNotEmpty) {
      return profileDescription;
    }

    final summaryDescription = summary.description?.trim();
    if (summaryDescription != null && summaryDescription.isNotEmpty) {
      return summaryDescription;
    }

    return fallback;
  }

  List<String> _splitOpeningHours(String openingHours, List<String> fallback) {
    final value = openingHours.trim();
    if (value.isEmpty) return fallback;

    final parts = value
        .split(RegExp(r'\s*(?:\r?\n|;|\|)\s*'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return fallback;
    if (parts.length <= 1) return [value];
    return parts.take(3).toList();
  }
}

class _BusinessStoreDetailsSheetBody extends StatelessWidget {
  const _BusinessStoreDetailsSheetBody({
    required this.businessName,
    required this.description,
    required this.productsCount,
    required this.openingHours,
    required this.hourChips,
    required this.address,
    required this.phone,
    required this.socialLinks,
    required this.launcher,
  });

  final String businessName;
  final String description;
  final int productsCount;
  final String openingHours;
  final List<String> hourChips;
  final String? address;
  final String? phone;
  final List<MapEntry<SocialMediaType, String>> socialLinks;
  final ExternalUrlLauncherService launcher;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 18.h),
        decoration: BoxDecoration(
          color: RoleTheme.client.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: RoleTheme.brandBorder,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                businessName,
                style: TextStyle(
                  color: RoleTheme.client.text,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                description,
                style: TextStyle(
                  color: RoleTheme.client.mutedText,
                  fontSize: 12.sp,
                  height: 1.32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 14.h),
              _DetailRow(
                icon: Icons.restaurant_menu_rounded,
                title: 'Productos disponibles',
                value: '$productsCount productos saludables',
                color: RoleTheme.iconHealth,
              ),
              if (openingHours.trim().isNotEmpty) ...[
                SizedBox(height: 10.h),
                _DetailSection(
                  icon: Icons.schedule_rounded,
                  title: 'Horario de atención',
                  color: RoleTheme.iconCalendar,
                  child: Wrap(
                    spacing: 7.w,
                    runSpacing: 7.h,
                    children: hourChips.isEmpty
                        ? [_DetailChip(label: openingHours)]
                        : hourChips
                              .map((hour) => _DetailChip(label: hour))
                              .toList(),
                  ),
                ),
              ],
              if (address?.isNotEmpty == true) ...[
                SizedBox(height: 10.h),
                _DetailRow(
                  icon: Icons.location_on_rounded,
                  title: 'Dirección',
                  value: address!,
                  color: RoleTheme.iconLocation,
                ),
              ],
              if (phone?.isNotEmpty == true) ...[
                SizedBox(height: 10.h),
                _DetailRow(
                  icon: Icons.phone_rounded,
                  title: 'Contacto',
                  value: phone!,
                  color: RoleTheme.iconCommunication,
                ),
              ],
              if (socialLinks.isNotEmpty) ...[
                SizedBox(height: 10.h),
                _DetailSection(
                  icon: Icons.share_rounded,
                  title: 'Redes sociales',
                  color: RoleTheme.iconCommunication,
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: socialLinks.map((entry) {
                      return _SocialButton(
                        type: entry.key,
                        onTap: () => _openUrl(context, entry.value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 17.sp),
              SizedBox(width: 7.w),
              Text(
                title,
                style: TextStyle(
                  color: RoleTheme.client.text,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: 9.h),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      icon: icon,
      title: title,
      color: color,
      child: Text(
        value,
        style: TextStyle(
          color: RoleTheme.client.mutedText,
          fontSize: 11.5.sp,
          height: 1.25,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: RoleTheme.client.surface,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: RoleTheme.brandBorder),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: RoleTheme.client.text,
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.type, required this.onTap});

  final SocialMediaType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: _backgroundColor(type),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Center(child: _icon(type)),
      ),
    );
  }

  Widget _icon(SocialMediaType type) {
    switch (type) {
      case SocialMediaType.facebook:
        return FaIcon(
          FontAwesomeIcons.facebookF,
          size: 15.sp,
          color: const Color(0xFF1877F2),
        );
      case SocialMediaType.instagram:
        return FaIcon(
          FontAwesomeIcons.instagram,
          size: 16.sp,
          color: const Color(0xFFC13584),
        );
      case SocialMediaType.whatsapp:
        return FaIcon(
          FontAwesomeIcons.whatsapp,
          size: 16.sp,
          color: const Color(0xFF25D366),
        );
      case SocialMediaType.website:
        return Icon(
          Icons.language_rounded,
          size: 17.sp,
          color: RoleTheme.iconCommunication,
        );
      case SocialMediaType.tiktok:
        return FaIcon(
          FontAwesomeIcons.tiktok,
          size: 15.sp,
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
}
