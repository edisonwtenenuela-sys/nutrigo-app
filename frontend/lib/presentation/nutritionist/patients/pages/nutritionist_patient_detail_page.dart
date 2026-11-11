import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/features/nutritionist/controllers/index.dart';
import 'package:emprendedor/features/nutritionist/helpers/nutritionist_patient_status_helper.dart';
import 'package:emprendedor/presentation/nutritionist/patients/widgets/index.dart';

class NutritionistPatientDetailPage extends StatelessWidget {
  const NutritionistPatientDetailPage({
    super.key,
    required this.patient,
  });

  final Map<String, dynamic> patient;

  final NutritionistPatientDetailController _screenController =
  const NutritionistPatientDetailController();

  AppBar _buildAppBar(RolePalette palette) {
    return AppBar(
      backgroundColor: palette.background,
      surfaceTintColor: palette.background,
      elevation: 0,
      centerTitle: true,
      foregroundColor: palette.text,
      title: Text(
        'Detalle del paciente',
        style: TextStyle(
          fontSize: 19.sp,
          fontWeight: FontWeight.w900,
          color: palette.text,
        ),
      ),
    );
  }

  Widget _buildMetricsRow({
    required int appointmentCount,
    required int completedCount,
    required int confirmedCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: NutritionistPatientMetricTile(
            icon: Icons.event_note_rounded,
            value: appointmentCount.toString(),
            label: 'Citas',
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: NutritionistPatientMetricTile(
            icon: Icons.check_circle_rounded,
            value: completedCount.toString(),
            label: 'Atendidas',
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: NutritionistPatientMetricTile(
            icon: Icons.pending_actions_rounded,
            value: confirmedCount.toString(),
            label: 'Activas',
          ),
        ),
      ],
    );
  }

  Widget _buildPageBody({
    required RolePalette palette,
    required String name,
    required String initial,
    required String? imageUrl,
    required AppointmentStatus? status,
    required Color statusColor,
    required int appointmentCount,
    required int completedCount,
    required int confirmedCount,
    required String lastDateText,
    required NutritionistPatientClinicalData clinicalData,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 22.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NutritionistPatientDetailHero(
            name: name,
            initial: initial,
            imageUrl: imageUrl,
            statusText: NutritionistPatientStatusHelper.statusText(status),
          ),

          SizedBox(height: 14.h),

          _buildMetricsRow(
            appointmentCount: appointmentCount,
            completedCount: completedCount,
            confirmedCount: confirmedCount,
          ),

          SizedBox(height: 18.h),

          const NutritionistPatientSectionTitle(
            icon: Icons.health_and_safety_rounded,
            title: 'Datos clínicos',
          ),

          SizedBox(height: 10.h),

          NutritionistPatientClinicalCard(data: clinicalData),

          SizedBox(height: 18.h),

          const NutritionistPatientSectionTitle(
            icon: Icons.medical_information_rounded,
            title: 'Ficha de seguimiento',
          ),

          SizedBox(height: 10.h),

          NutritionistPatientInfoTile(
            icon: Icons.calendar_month_rounded,
            title: 'Última cita registrada',
            value: lastDateText,
            color: statusColor,
          ),

          NutritionistPatientInfoTile(
            icon: Icons.health_and_safety_rounded,
            title: 'Estado dentro de NutriGo',
            value: NutritionistPatientStatusHelper.statusDescription(status),
            color: statusColor,
          ),

          NutritionistPatientInfoTile(
            icon: Icons.route_rounded,
            title: 'Continuidad de atención',
            value: NutritionistPatientStatusHelper.continuityText(status),
            color: palette.primary,
          ),

          SizedBox(height: 6.h),

          NutritionistPatientCareNoteCard(
            statusColor: statusColor,
            statusText: NutritionistPatientStatusHelper.statusText(status),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;
    final details = _screenController.buildViewData(patient);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: _buildAppBar(palette),
      body: _buildPageBody(
        palette: palette,
        name: details.name,
        initial: details.initial,
        imageUrl: details.imageUrl,
        status: details.status,
        statusColor: details.statusColor,
        appointmentCount: details.appointmentCount,
        completedCount: details.completedCount,
        confirmedCount: details.confirmedCount,
        lastDateText: details.lastDateText,
        clinicalData: details.clinicalData,
      ),
    );
  }
}