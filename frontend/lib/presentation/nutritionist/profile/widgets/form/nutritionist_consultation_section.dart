import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';
import 'package:emprendedor/features/nutritionist/controllers/nutritionist_profile_controller.dart';
import 'package:emprendedor/presentation/nutritionist/profile/pages/nutritionist_availability_page.dart';
import 'package:emprendedor/presentation/nutritionist/profile/widgets/form/nutritionist_maps_button.dart';
import 'package:emprendedor/presentation/nutritionist/profile/widgets/form/nutritionist_profile_input.dart';
import 'package:emprendedor/presentation/nutritionist/profile/widgets/layout/nutritionist_profile_section_title.dart';

class NutritionistConsultationSection extends StatelessWidget {
  const NutritionistConsultationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NutritionistProfileController>();
    final selectedMode = controller.selectedMode;
    const palette = RoleTheme.nutritionist;

    final showVirtualFields =
        selectedMode == NutritionistConsultationMode.virtual ||
            selectedMode == NutritionistConsultationMode.ambos;

    final showPresencialFields =
        selectedMode == NutritionistConsultationMode.presencial ||
            selectedMode == NutritionistConsultationMode.ambos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NutritionistProfileSectionTitle(
          icon: Icons.calendar_month_outlined,
          title: 'Atención y consultas',
          subtitle:
          'Configura cómo ofrecerás tus consultas dentro de la plataforma.',
        ),
        SizedBox(height: 14.h),
        Text(
          'Modalidad de consulta',
          style: TextStyle(
            color: palette.text,
            fontSize: 11.3.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 6.h),
        DropdownButtonFormField<NutritionistConsultationMode>(
          initialValue: controller.selectedMode,
          decoration: _dropdownDecoration(),
          dropdownColor: palette.surface,
          style: TextStyle(
            color: palette.text,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
          items: NutritionistConsultationMode.values.map((mode) {
            return DropdownMenuItem<NutritionistConsultationMode>(
              value: mode,
              child: Text(mode.label),
            );
          }).toList(),
          onChanged: controller.isSaving
              ? null
              : (value) {
            if (value == null) return;
            controller.setConsultationMode(value);
            controller.clearError();
          },
        ),
        SizedBox(height: 12.h),
        NutritionistProfileInput(
          controller: controller.priceController,
          label: 'Precio de consulta',
          icon: Icons.attach_money_outlined,
          hintText: 'Ej: 20.00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: controller.validatePrice,
          onChanged: controller.clearError,
        ),
        SizedBox(height: 12.h),
        _AvailabilitySettingsCard(controller: controller),
        if (showVirtualFields) ...[
          SizedBox(height: 12.h),
          NutritionistProfileInput(
            controller: controller.meetingLinkController,
            label: 'Enlace para cita virtual',
            icon: Icons.link_rounded,
            hintText: 'Ej: https://meet.google.com/abc-defg-hij',
            keyboardType: TextInputType.url,
            validator: controller.validateMeetingLink,
            onChanged: controller.clearError,
          ),
        ],
        if (showPresencialFields) ...[
          SizedBox(height: 12.h),
          NutritionistProfileInput(
            controller: controller.consultationAddressController,
            label: 'Dirección de atención presencial',
            icon: Icons.location_on_outlined,
            hintText: 'Ej: Av. Principal y Calle 10, consultorio 203',
            maxLines: 2,
            validator: controller.validateConsultationAddress,
            onChanged: controller.clearError,
          ),
          SizedBox(height: 6.h),
          const NutritionistMapsButton(),
        ],
        SizedBox(height: 12.h),
        NutritionistProfileInput(
          controller: controller.consultationInstructionsController,
          label: 'Indicaciones para el paciente',
          icon: Icons.info_outline_rounded,
          hintText: 'Ej: Conectarse 5 minutos antes o llevar exámenes médicos.',
          maxLines: 2,
          onChanged: controller.clearError,
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration() {
    const palette = RoleTheme.nutritionist;
    final radius = BorderRadius.circular(18.r);

    return InputDecoration(
      prefixIcon: Padding(
        padding: EdgeInsets.only(left: 10.w, right: 8.w),
        child: Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.video_call_outlined,
            color: RoleTheme.iconColorFor(
              Icons.video_call_outlined,
              fallback: palette.primary,
            ),
            size: 18.sp,
          ),
        ),
      ),
      prefixIconConstraints: BoxConstraints(minWidth: 58.w),
      filled: true,
      fillColor: palette.background,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      border: OutlineInputBorder(borderRadius: radius),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: palette.primary.withValues(alpha: 0.10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: palette.primary, width: 1.3.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: RoleTheme.iconDanger.withValues(alpha: 0.55),
          width: 1.2.w,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: RoleTheme.iconDanger.withValues(alpha: 0.75),
          width: 1.3.w,
        ),
      ),
    );
  }
}

class _AvailabilitySettingsCard extends StatelessWidget {
  const _AvailabilitySettingsCard({required this.controller});

  final NutritionistProfileController controller;

  void _openAvailability(BuildContext context) {
    AppNavigator.push(context, const NutritionistAvailabilityPage());
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: controller.isSaving ? null : () => _openAvailability(context),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(13.w),
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: palette.primary.withValues(alpha: 0.16)),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 8.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  color: RoleTheme.iconColorFor(
                    Icons.schedule_rounded,
                    fallback: palette.primary,
                  ),
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disponibilidad de citas',
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 12.3.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Configura días y horarios para que los clientes agenden.',
                      style: TextStyle(
                        color: palette.mutedText,
                        fontSize: 10.6.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: RoleTheme.iconColorFor(
                  Icons.chevron_right_rounded,
                  fallback: palette.primary,
                ),
                size: 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}