import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/features/nutritionist/controllers/nutritionist_appointment_actions_controller.dart';

class NutritionistAppointmentActions extends StatelessWidget {
  final AppointmentModel appointment;

  const NutritionistAppointmentActions({
    super.key,
    required this.appointment,
  });

  static const _mapsButtonLabel = 'Ver ubicación';

  @override
  Widget build(BuildContext context) {
    final controller = NutritionistAppointmentActionsController(
      appointment: appointment,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (appointment.isVirtual) ...[
          if (controller.canOpenMeetingLink)
            _MiniActionButton(
              icon: Icons.video_call_rounded,
              label: 'Abrir Meet',
              color: RoleTheme.nutritionist.primary,
              expanded: true,
              onTap: controller.openMeetingLink,
            )
          else if (controller.isMeetingLinkPending)
            const _PendingActionChip(
              icon: Icons.hourglass_top_rounded,
              label: 'Generando Meet automático',
            )
          else if (controller.needsManualMeetingLink)
              const _PendingActionChip(
                icon: Icons.edit_calendar_rounded,
                label: 'Configura Meet de respaldo',
              ),
        ] else if (controller.canOpenMaps) ...[
          _MiniActionButton(
            icon: Icons.map_rounded,
            label: _mapsButtonLabel,
            color: RoleTheme.nutritionist.primary,
            expanded: true,
            onTap: controller.openMaps,
          ),
        ],
        if (controller.canOpenWhatsApp) ...[
          SizedBox(height: 7.h),
          _MiniActionButton(
            icon: Icons.chat_rounded,
            label: 'Contactar cliente',
            color: RoleTheme.iconValidation,
            expanded: true,
            onTap: controller.openWhatsApp,
          ),
        ],
      ],
    );
  }
}

class _PendingActionChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PendingActionChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      width: double.infinity,
      height: 31.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: palette.mutedText.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(
          color: palette.mutedText.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 13.sp,
            color: RoleTheme.iconColorFor(icon, fallback: palette.mutedText),
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.mutedText,
                fontSize: 10.4.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool expanded;

  const _MiniActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: expanded ? double.infinity : null,
      height: 31.h,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 13.sp,
          color: RoleTheme.iconColorFor(icon, fallback: color),
        ),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.4.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          backgroundColor: color.withValues(alpha: 0.055),
          side: BorderSide(color: color.withValues(alpha: 0.28)),
          padding: EdgeInsets.symmetric(horizontal: 9.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.r),
          ),
        ),
      ),
    );

    return expanded ? button : IntrinsicWidth(child: button);
  }
}
