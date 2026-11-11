import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:emprendedor/core/utils/ecuador_time_utils.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/presentation/client/appointments/pages/appointment_detail_page.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/review/nutritionist_review_dialog.dart';
import 'package:emprendedor/presentation/shared/widgets/buttons/app_action_button.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentCard({super.key, required this.appointment});

  Color _statusColor() {
    switch (appointment.status) {
      case AppointmentStatus.pending:
        return RoleTheme.iconWarning;
      case AppointmentStatus.confirmed:
        return RoleTheme.iconCalendar;
      case AppointmentStatus.completed:
        return RoleTheme.iconValidation;
      case AppointmentStatus.cancelled:
        return RoleTheme.iconDanger;
      case AppointmentStatus.noShow:
        return RoleTheme.brandMutedText;
    }
  }

  IconData _statusIcon() {
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

  Future<void> _openReviewDialog(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      builder: (_) => NutritionistReviewDialog(appointment: appointment),
    );
  }

  void _openDetail(BuildContext context) {
    AppNavigator.push(context, AppointmentDetailPage(appointment: appointment));
  }

  Widget _buildHeader({
    required RolePalette palette,
    required Color statusColor,
    required DateTime date,
  }) {
    final appointmentIcon = appointment.isVirtual
        ? Icons.video_call_rounded
        : Icons.location_on_rounded;

    final appointmentIconColor = RoleTheme.iconColorFor(
      appointmentIcon,
      fallback: statusColor,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: appointmentIconColor.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Icon(
            appointmentIcon,
            color: appointmentIconColor,
            size: 25.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appointment.nutritionistName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  color: palette.text,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                DateFormat('EEE, dd MMM yyyy - HH:mm', 'es').format(date),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.mutedText,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5.sp,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 6.w),
        Icon(
          Icons.chevron_right_rounded,
          size: 22.sp,
          color: appointmentIconColor,
        ),
      ],
    );
  }

  Widget _buildBadges(RolePalette palette, Color statusColor) {
    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: [
        _SmallBadge(
          text: appointment.consultationMode.label,
          color: RoleTheme.iconCalendar,
          icon: appointment.isVirtual
              ? Icons.video_call_rounded
              : Icons.location_on_rounded,
        ),
        _SmallBadge(
          text: appointment.status.label,
          color: statusColor,
          icon: _statusIcon(),
        ),
        if (appointment.isReviewed && appointment.reviewRating != null)
          _RatingBadge(rating: appointment.reviewRating!),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = EcuadorTimeUtils.timestampToEcuadorDateTime(
      appointment.appointmentDate,
    );
    final statusColor = _statusColor();
    const palette = RoleTheme.client;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: () => _openDetail(context),
          child: Container(
            padding: EdgeInsets.all(13.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: statusColor.withValues(alpha: 0.14)),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.04),
                  blurRadius: 10.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(
                  palette: palette,
                  statusColor: statusColor,
                  date: date,
                ),
                SizedBox(height: 10.h),
                _buildBadges(palette, statusColor),
                if (_supportMessage != null) ...[
                  SizedBox(height: 10.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(13.r),
                    ),
                    child: Text(
                      _supportMessage!,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11.2.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
                if (appointment.isReviewed) ...[
                  SizedBox(height: 10.h),
                  const _ReviewStateBadge(
                    label: 'Valoración registrada',
                    color: RoleTheme.iconRating,
                  ),
                ],
                if (appointment.canClientReview) ...[
                  SizedBox(height: 10.h),
                  ClientActionButton(
                    label: 'Valorar nutricionista',
                    icon: Icons.star_rounded,
                    height: 36.h,
                    fontSize: 11.5.sp,
                    radius: 13.r,
                    onPressed: () => _openReviewDialog(context),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? get _supportMessage {
    if (appointment.isVirtual) {
      return appointment.status == AppointmentStatus.confirmed
          ? 'Toca para unirte a la cita virtual.'
          : 'El enlace aparecerá cuando el nutricionista confirme.';
    }

    if (appointment.isPresencial &&
        (appointment.appointmentAddress?.trim().isNotEmpty ?? false)) {
      return 'Toca para ver la dirección de la cita.';
    }

    if (appointment.status == AppointmentStatus.pending) {
      return 'Esperando confirmación del nutricionista.';
    }

    if (appointment.status == AppointmentStatus.noShow) {
      return 'El nutricionista marcó esta cita como no asistida.';
    }

    if (appointment.status == AppointmentStatus.cancelled) {
      return 'La cita fue cancelada.';
    }

    return null;
  }
}

class _SmallBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const _SmallBadge({required this.text, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    final semanticIconColor = icon == null
        ? color
        : RoleTheme.iconColorFor(icon!, fallback: color);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: semanticIconColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: semanticIconColor, size: 12.sp),
            SizedBox(width: 4.w),
          ],
          Text(
            text,
            style: TextStyle(
              color: semanticIconColor,
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final int rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    final safeRating = rating.clamp(1, 5);
    const color = RoleTheme.iconRating;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: color, size: 12.sp),
          SizedBox(width: 4.w),
          Text(
            '$safeRating ${safeRating == 1 ? 'estrella' : 'estrellas'}',
            style: TextStyle(
              color: color,
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewStateBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _ReviewStateBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final semanticIconColor = RoleTheme.iconColorFor(
      Icons.check_circle_rounded,
      fallback: color,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: semanticIconColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: semanticIconColor,
            size: 15.sp,
          ),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
              color: semanticIconColor,
            ),
          ),
        ],
      ),
    );
  }
}
