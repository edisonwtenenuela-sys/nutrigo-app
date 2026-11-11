import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:emprendedor/core/utils/ecuador_time_utils.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/presentation/nutritionist/appointments/widgets/nutritionist_card/nutritionist_status_badge.dart';

class NutritionistAppointmentHeader extends StatelessWidget {
  final AppointmentModel appointment;

  const NutritionistAppointmentHeader({super.key, required this.appointment});

  static const _dateFormatPattern = 'EEE, dd MMM yyyy - HH:mm';

  Color get _statusColor {
    switch (appointment.status) {
      case AppointmentStatus.pending:
        return RoleTheme.iconWarning;
      case AppointmentStatus.confirmed:
        return RoleTheme.nutritionist.primary;
      case AppointmentStatus.completed:
        return RoleTheme.iconValidation;
      case AppointmentStatus.cancelled:
        return RoleTheme.iconDanger;
      case AppointmentStatus.noShow:
        return RoleTheme.nutritionist.mutedText;
    }
  }

  IconData get _statusIcon {
    switch (appointment.status) {
      case AppointmentStatus.pending:
        return Icons.pending_actions_rounded;
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

  String _formattedDate(DateTime date) {
    return DateFormat(_dateFormatPattern, 'es').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final date = EcuadorTimeUtils.timestampToEcuadorDateTime(
      appointment.appointmentDate,
    );
    const palette = RoleTheme.nutritionist;

    return Row(
      children: [
        _ClientAvatar(imageUrl: appointment.clientProfileImageUrl),
        SizedBox(width: 11.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appointment.clientName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15.sp,
                  color: palette.text,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                _formattedDate(date),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.mutedText,
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        NutritionistStatusBadge(
          color: _statusColor,
          icon: _statusIcon,
          label: appointment.status.label,
        ),
      ],
    );
  }
}

class _ClientAvatar extends StatelessWidget {
  final String? imageUrl;

  const _ClientAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: 46.w,
      height: 46.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.primary.withValues(alpha: 0.10),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: imageUrl!.trim(),
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 450),
              fadeOutDuration: const Duration(milliseconds: 120),
              placeholder: (_, _) => const _AvatarPlaceholder(),
              errorWidget: (_, _, _) => const _AvatarPlaceholder(),
            )
          : const _AvatarPlaceholder(),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Center(
      child: Icon(
        Icons.person_rounded,
        color: RoleTheme.iconColorFor(
          Icons.person_rounded,
          fallback: palette.primary,
        ).withValues(alpha: 0.55),
        size: 20.sp,
      ),
    );
  }
}
