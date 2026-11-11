import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/features/client/controllers/appointment_detail_header_controller.dart';

class AppointmentDetailHeaderCard extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentDetailHeaderCard({super.key, required this.appointment});

  IconData get _statusIcon {
    switch (appointment.status) {
      case AppointmentStatus.pending:
        return Icons.schedule_rounded;
      case AppointmentStatus.confirmed:
        return Icons.check_circle_rounded;
      case AppointmentStatus.completed:
        return Icons.verified_rounded;
      case AppointmentStatus.cancelled:
        return Icons.cancel_rounded;
      case AppointmentStatus.noShow:
        return Icons.person_off_rounded;
    }
  }

  Color get _statusColor {
    return RoleTheme.iconColorFor(_statusIcon, fallback: RoleTheme.iconCalendar);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: RoleTheme.brandBadgeBackground,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.07),
            blurRadius: 14.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Row(
        children: [
          _NutritionistAvatar(appointment: appointment),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.nutritionistName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RoleTheme.brandText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 7.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: RoleTheme.brandSurface,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, color: statusColor, size: 13.sp),
                      SizedBox(width: 4.w),
                      Text(
                        appointment.status.label,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionistAvatar extends StatefulWidget {
  final AppointmentModel appointment;

  const _NutritionistAvatar({required this.appointment});

  @override
  State<_NutritionistAvatar> createState() => _NutritionistAvatarState();
}

class _NutritionistAvatarState extends State<_NutritionistAvatar> {
  late final AppointmentDetailHeaderController _controller;
  late final Future<String?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _controller = AppointmentDetailHeaderController();
    final storedImage = widget.appointment.nutritionistProfileImageUrl?.trim();
    if (storedImage != null && storedImage.isNotEmpty) {
      _controller.cacheNutritionistImage(
        widget.appointment.nutritionistUserId,
        storedImage,
      );
      _imageFuture = Future.value(storedImage);
    } else {
      final cachedImage = _controller.cachedNutritionistImage(
        widget.appointment.nutritionistUserId,
      );
      _imageFuture = cachedImage != null
          ? Future.value(cachedImage)
          : _controller.loadNutritionistImage(
        widget.appointment.nutritionistUserId,
      );
    }
  }

  IconData get _modeIcon {
    return widget.appointment.isVirtual
        ? Icons.video_call_rounded
        : Icons.location_on_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final modeColor = RoleTheme.iconColorFor(
      _modeIcon,
      fallback: RoleTheme.iconCalendar,
    );

    return SizedBox(
      width: 62.w,
      height: 62.w,
      child: Stack(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            padding: EdgeInsets.all(3.w),
            decoration: const BoxDecoration(
              color: RoleTheme.brandSurface,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: FutureBuilder<String?>(
                future: _imageFuture,
                builder: (context, snapshot) {
                  final imageUrl = snapshot.data?.trim();
                  final hasImage = imageUrl != null && imageUrl.isNotEmpty;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.expand();
                  }

                  if (!hasImage) {
                    return _AvatarFallback(icon: _modeIcon);
                  }

                  return CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 450),
                    fadeOutDuration: const Duration(milliseconds: 120),
                    placeholder: (context, url) => const SizedBox.expand(),
                    errorWidget: (context, url, error) {
                      return _AvatarFallback(icon: _modeIcon);
                    },
                  );
                },
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 2.w,
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: RoleTheme.brandSurface,
                borderRadius: BorderRadius.circular(9.r),
                border: Border.all(color: modeColor.withValues(alpha: 0.20)),
              ),
              child: Icon(_modeIcon, color: modeColor, size: 13.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final IconData icon;

  const _AvatarFallback({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RoleTheme.brandChipBackground,
      child: Icon(
        icon,
        color: RoleTheme.iconColorFor(icon, fallback: RoleTheme.iconProfile),
        size: 30.sp,
      ),
    );
  }
}