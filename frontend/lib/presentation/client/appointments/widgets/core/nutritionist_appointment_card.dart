import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/features/client/controllers/appointment_controller.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/form/appointment_date_time_selector.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/form/appointment_notes_field.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/form/appointment_pay_button.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/core/price_box.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/nutritionist/index.dart';
import 'package:emprendedor/presentation/shared/widgets/buttons/app_action_button.dart';

class NutritionistAppointmentCard extends StatelessWidget {
  final NutritionistProfileModel nutritionist;
  final AppointmentController controller;

  final VoidCallback onPickDate;
  final VoidCallback onPay;

  final VoidCallback? onSelect;
  final VoidCallback? onBackToList;

  final bool showBookingForm;

  final NutritionistConsultationMode? selectedMode;
  final ValueChanged<NutritionistConsultationMode>? onModeChanged;

  const NutritionistAppointmentCard({
    super.key,
    required this.nutritionist,
    required this.controller,
    required this.onPickDate,
    required this.onPay,
    this.onSelect,
    this.onBackToList,
    this.showBookingForm = true,
    this.selectedMode,
    this.onModeChanged,
  });

  List<NutritionistConsultationMode> get _availableModes {
    switch (nutritionist.consultationMode) {
      case NutritionistConsultationMode.virtual:
        return [NutritionistConsultationMode.virtual];
      case NutritionistConsultationMode.presencial:
        return [NutritionistConsultationMode.presencial];
      case NutritionistConsultationMode.ambos:
        return [
          NutritionistConsultationMode.virtual,
          NutritionistConsultationMode.presencial,
        ];
    }
  }

  String get _descriptionText {
    final description = nutritionist.professionalDescription?.trim();
    if (description != null && description.isNotEmpty) {
      return description;
    }

    return 'Especialista en planes alimenticios personalizados.';
  }

  Widget _buildCollapsedActions(double price) {
    return Row(
      children: [
        Expanded(child: NutritionistMiniPrice(price: price)),
        SizedBox(width: 10.w),
        SizedBox(
          width: 106.w,
          child: ClientActionButton(
            label: 'Agendar',
            height: 40.h,
            fontSize: 12.sp,
            radius: 13.r,
            onPressed: onSelect,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildExpandedForm(double price) {
    return [
      PriceBox(price: price),
      SizedBox(height: 16.h),
      AppointmentSectionLabel(
        icon: Icons.tune_rounded,
        label: 'Modalidad de atención',
      ),
      SizedBox(height: 8.h),
      ConsultationModeSelector(
        modes: _availableModes,
        selectedMode: selectedMode,
        onChanged: onModeChanged,
      ),
      SizedBox(height: 15.h),
      AppointmentDateTimeSelector(
        controller: controller,
        onPickDate: onPickDate,
      ),
      SizedBox(height: 14.h),
      AppointmentNotesField(controller: controller),
      SizedBox(height: 18.h),
      AppointmentPayButton(isSaving: controller.isSaving, onPressed: onPay),
      SizedBox(height: 12.h),
      const AppointmentGuaranteeCard(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final price = nutritionist.consultationPrice ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 13.h),
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: RoleTheme.iconCalendar.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: RoleTheme.iconHealth.withValues(alpha: 0.035),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBookingForm && onBackToList != null) ...[
            AppointmentChangeNutritionistButton(onPressed: onBackToList!),
            SizedBox(height: 12.h),
          ],
          NutritionistCardHeader(
            nutritionist: nutritionist,
            isExpanded: showBookingForm,
          ),
          if (showBookingForm) ...[
            SizedBox(height: 12.h),
            NutritionistDescriptionPreview(
              nutritionistName: nutritionist.name,
              description: _descriptionText,
              maxLines: 4,
            ),
          ],
          SizedBox(height: 12.h),
          if (!showBookingForm) _buildCollapsedActions(price),
          if (showBookingForm) ..._buildExpandedForm(price),
        ],
      ),
    );
  }
}