import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';

class AppointmentStatusActions extends StatelessWidget {
  final AppointmentStatus currentStatus;
  final bool appointmentHasPassed;
  final ValueChanged<AppointmentStatus> onUpdateStatus;

  const AppointmentStatusActions({
    super.key,
    required this.currentStatus,
    required this.appointmentHasPassed,
    required this.onUpdateStatus,
  });

  bool get _isFinalStatus {
    return currentStatus == AppointmentStatus.completed ||
        currentStatus == AppointmentStatus.cancelled ||
        currentStatus == AppointmentStatus.noShow;
  }

  bool get _isConfirmed => currentStatus == AppointmentStatus.confirmed;

  Widget _buildFinalStatusMessage() {
    const palette = RoleTheme.nutritionist;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: palette.mutedText.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(
          color: palette.mutedText.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: RoleTheme.iconColorFor(
              Icons.lock_outline_rounded,
              fallback: palette.mutedText,
            ),
            size: 15.sp,
          ),
          SizedBox(width: 7.w),
          Expanded(
            child: Text(
              'Esta cita ya tiene un estado final.',
              style: TextStyle(
                color: palette.mutedText,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoColumns(Widget first, Widget second) {
    return Row(
      children: [
        Expanded(child: first),
        SizedBox(width: 8.w),
        Expanded(child: second),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    if (_isFinalStatus) {
      return _buildFinalStatusMessage();
    }

    final confirmButton = _ActionButton(
      label: 'Confirmar',
      icon: Icons.check_circle_outline_rounded,
      color: palette.primary,
      filled: true,
      disabled: _isConfirmed,
      onPressed: () => onUpdateStatus(AppointmentStatus.confirmed),
    );

    final cancelButton = _ActionButton(
      label: 'Cancelar',
      icon: Icons.cancel_rounded,
      color: RoleTheme.iconDanger,
      onPressed: () => onUpdateStatus(AppointmentStatus.cancelled),
    );

    final completeButton = _ActionButton(
      label: 'Completar',
      icon: Icons.verified_rounded,
      color: RoleTheme.iconValidation,
      filled: true,
      disabled: !appointmentHasPassed,
      onPressed: () => onUpdateStatus(AppointmentStatus.completed),
    );

    final noShowButton = _ActionButton(
      label: 'No asistió',
      icon: Icons.person_off_rounded,
      color: palette.mutedText,
      disabled: !appointmentHasPassed,
      onPressed: () => onUpdateStatus(AppointmentStatus.noShow),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones',
          style: TextStyle(
            fontSize: 11.2.sp,
            fontWeight: FontWeight.w900,
            color: palette.text,
          ),
        ),
        SizedBox(height: 7.h),
        if (_isConfirmed) ...[
          _buildTwoColumns(completeButton, noShowButton),
          SizedBox(height: 8.h),
          cancelButton,
        ] else
          _buildTwoColumns(confirmButton, cancelButton),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool disabled;
  final bool filled;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.disabled = false,
    this.filled = false,
  });

  Color _borderColor(RolePalette palette) {
    return disabled
        ? palette.mutedText.withValues(alpha: 0.18)
        : color.withValues(alpha: filled ? 0 : 0.30);
  }

  Color _backgroundColor(RolePalette palette) {
    if (disabled) return palette.mutedText.withValues(alpha: 0.04);
    if (filled) return color;
    return color.withValues(alpha: 0.055);
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    final foregroundColor = filled && !disabled ? palette.surface : color;

    return SizedBox(
      width: double.infinity,
      height: 32.h,
      child: OutlinedButton.icon(
        onPressed: disabled ? null : onPressed,
        icon: Icon(
          icon,
          size: 13.sp,
          color: RoleTheme.iconColorFor(icon, fallback: foregroundColor),
        ),
        label: Text(
          label,
          style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w900),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          disabledForegroundColor: palette.mutedText.withValues(alpha: 0.55),
          backgroundColor: _backgroundColor(palette),
          side: BorderSide(color: _borderColor(palette)),
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.r),
          ),
        ),
      ),
    );
  }
}