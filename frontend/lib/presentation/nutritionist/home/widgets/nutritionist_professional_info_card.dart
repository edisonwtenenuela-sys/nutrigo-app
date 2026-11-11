import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'nutritionist_quick_info_card.dart';

class NutritionistProfessionalInfoCard extends StatelessWidget {
  final String? specialty;
  final String? consultationMode;
  final double? consultationPrice;
  final bool isVerified;
  final bool isResolvingStatus;
  final bool isRejected;
  final String? rejectionMessage;
  final VoidCallback? onEditPressed;

  const NutritionistProfessionalInfoCard({
    super.key,
    required this.specialty,
    required this.consultationMode,
    required this.consultationPrice,
    this.isVerified = true,
    this.isResolvingStatus = false,
    this.isRejected = false,
    this.rejectionMessage,
    this.onEditPressed,
  });

  static const String _adviceText =
      'Mantén actualizada tu información profesional para generar confianza en los pacientes.';

  String _specialtyLabel() {
    final value = specialty?.trim() ?? '';
    return value.isNotEmpty ? value : 'Especialidad no definida';
  }

  String _modeLabel() {
    final rawMode = (consultationMode ?? 'Virtual').trim();
    final normalizedMode = rawMode.toLowerCase();

    if (normalizedMode == 'ambos' ||
        normalizedMode == 'virtual y presencial' ||
        normalizedMode == 'presencial y virtual') {
      return 'Virtual\nPresencial';
    }

    return rawMode.isNotEmpty ? rawMode : 'Virtual';
  }

  String _priceLabel() {
    if (consultationPrice == null) return 'Sin configurar';

    return '\$${consultationPrice!.toStringAsFixed(0)}';
  }

  Widget _buildTitle(RolePalette palette) {
    final icon = isVerified
        ? Icons.workspace_premium_rounded
        : Icons.lock_clock_rounded;

    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
            size: 19.sp,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            _specialtyLabel(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.text,
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: NutritionistQuickInfoCard(
            icon: Icons.video_call_rounded,
            title: 'Modalidad',
            value: _modeLabel(),
            color: RoleTheme.iconColorFor(Icons.video_call_rounded),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: NutritionistQuickInfoCard(
            icon: Icons.attach_money_rounded,
            title: 'Consulta',
            value: _priceLabel(),
            color: RoleTheme.iconColorFor(Icons.attach_money_rounded),
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton(RolePalette palette) {
    if (isResolvingStatus || !isRejected || onEditPressed == null) {
      return const SizedBox.shrink();
    }

    final icon = Icons.edit_note_rounded;

    return Padding(
      padding: EdgeInsets.only(top: 14.h),
      child: SizedBox(
        width: double.infinity,
        height: 42.h,
        child: OutlinedButton.icon(
          onPressed: onEditPressed,
          icon: Icon(
            icon,
            color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
            size: 18.sp,
          ),
          label: Text(
            'Corregir y reenviar solicitud',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: palette.primary,
            backgroundColor: palette.primary.withValues(alpha: 0.06),
            side: BorderSide(color: palette.primary.withValues(alpha: 0.20)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdviceCard(RolePalette palette) {
    final icon = isRejected
        ? Icons.cancel_rounded
        : Icons.tips_and_updates_rounded;
    final accentColor = isRejected ? RoleTheme.iconDanger : palette.secondary;
    final message = rejectionMessage?.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: RoleTheme.iconColorFor(icon, fallback: accentColor),
            size: 22.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isRejected)
                  Text(
                    'Solicitud rechazada',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                if (isRejected) SizedBox(height: 3.h),
                Text(
                  isRejected
                      ? (message != null && message.isNotEmpty
                            ? message
                            : 'Revisa los datos indicados y envía nuevamente tu solicitud.')
                      : _adviceText,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 12.2.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(palette),
          SizedBox(height: 14.h),
          _buildSummaryRow(),
          SizedBox(height: 14.h),
          _buildAdviceCard(palette),
          _buildEditButton(palette),
        ],
      ),
    );
  }
}
