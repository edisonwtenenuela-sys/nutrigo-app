import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/utils/ecuador_time_utils.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/data/repositories/client/appointment_repository.dart';
import 'package:emprendedor/features/client/controllers/appointment_detail_controller.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/detail/appointment_detail_action_button.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/detail/appointment_detail_header_card.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/detail/appointment_detail_overview.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/detail/appointment_info_card.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/detail/appointment_review_summary_card.dart';

class AppointmentDetailPage extends StatelessWidget {
  final AppointmentModel appointment;

  AppointmentDetailPage({super.key, required this.appointment});

  final AppointmentRepository _repository = AppointmentRepository();

  AppointmentDetailController _controllerFor(AppointmentModel appointment) {
    return AppointmentDetailController(appointment: appointment);
  }

  AppBar _buildAppBar(RolePalette palette) {
    return AppBar(
      backgroundColor: palette.background,
      surfaceTintColor: palette.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Detalle de cita',
        style: TextStyle(
          fontSize: 19.sp,
          fontWeight: FontWeight.w900,
          color: palette.text,
        ),
      ),
    );
  }

  List<Widget> _buildBaseInfo(
    AppointmentModel appointment,
    DateTime date,
    AppointmentDetailController controller,
  ) {
    return [
      AppointmentDetailHeaderCard(appointment: appointment),
      SizedBox(height: 14.h),
      AppointmentDetailOverview(appointment: appointment, date: date),
      SizedBox(height: 12.h),
      AppointmentInfoCard(
        icon: Icons.payments_rounded,
        title: 'Pago',
        value: appointment.paymentStatus.label,
      ),
      AppointmentInfoCard(
        icon: Icons.attach_money_rounded,
        title: 'Valor de consulta',
        value: controller.formatAmount(),
      ),
      AppointmentInfoCard(
        icon: Icons.info_outline_rounded,
        title: 'Indicaciones',
        value: appointment.appointmentInstructions,
      ),
      if (appointment.notes?.trim().isNotEmpty ?? false)
        AppointmentInfoCard(
          icon: Icons.notes_rounded,
          title: 'Notas del cliente',
          value: appointment.notes,
        ),
      if (appointment.recommendations?.trim().isNotEmpty ?? false)
        AppointmentInfoCard(
          icon: Icons.health_and_safety_rounded,
          title: 'Recomendaciones',
          value: appointment.recommendations,
        ),
      if (appointment.isReviewed && appointment.reviewRating != null)
        AppointmentReviewSummaryCard(appointment: appointment),
    ];
  }

  List<Widget> _buildVirtualSection(
    AppointmentModel appointment,
    AppointmentDetailController controller,
  ) {
    if (!appointment.isVirtual) return const [];

    return [
      AppointmentInfoCard(
        icon: Icons.lock_clock_rounded,
        title: 'Acceso a la videollamada',
        value: controller.virtualAccessMessage,
      ),
      AppointmentDetailActionButton(
        icon: Icons.video_call_rounded,
        label: controller.virtualActionLabel,
        color: RoleTheme.iconCalendar,
        onPressed: controller.canJoinVirtualAppointment
            ? controller.openMeetingLink
            : null,
      ),
    ];
  }

  List<Widget> _buildInPersonSection(
    AppointmentModel appointment,
    AppointmentDetailController controller,
  ) {
    if (!appointment.isPresencial) return const [];

    return [
      AppointmentInfoCard(
        icon: Icons.place_rounded,
        title: 'Dirección',
        value: appointment.appointmentAddress,
      ),
      AppointmentDetailActionButton(
        icon: Icons.map_rounded,
        label: 'Abrir en Google Maps',
        color: RoleTheme.iconInfo,
        onPressed: controller.canOpenMaps ? controller.openMaps : null,
      ),
    ];
  }

  Widget _buildWhatsAppAction(
    AppointmentModel appointment,
    AppointmentDetailController controller,
  ) {
    return AppointmentDetailActionButton(
      icon: Icons.chat_rounded,
      label: 'Contactar por WhatsApp',
      color: RoleTheme.iconValidation,
      onPressed: appointment.hasContactPhone ? controller.openWhatsApp : null,
    );
  }

  List<Widget> _buildDetailActions(
    AppointmentModel appointment,
    AppointmentDetailController controller,
  ) {
    return [
      ..._buildVirtualSection(appointment, controller),
      ..._buildInPersonSection(appointment, controller),
      _buildWhatsAppAction(appointment, controller),
    ];
  }

  Widget _buildBody(
    AppointmentModel appointment,
    DateTime date,
    AppointmentDetailController controller,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      child: Column(
        children: [
          ..._buildBaseInfo(appointment, date, controller),
          ..._buildDetailActions(appointment, controller),
        ],
      ),
    );
  }

  Stream<AppointmentModel?>? _liveAppointmentStream() {
    final appointmentId = appointment.id;
    if (appointmentId == null || appointmentId.trim().isEmpty) return null;

    return _repository.watchAppointmentByIdForClient(
      appointmentId,
      appointment.clientUserId,
    );
  }

  Widget _buildScaffold(AppointmentModel appointment) {
    final date = EcuadorTimeUtils.timestampToEcuadorDateTime(
      appointment.appointmentDate,
    );
    final controller = _controllerFor(appointment);
    const palette = RoleTheme.client;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: _buildAppBar(palette),
      body: _buildBody(appointment, date, controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppointmentModel?>(
      stream: _liveAppointmentStream(),
      initialData: appointment,
      builder: (context, snapshot) {
        return _buildScaffold(snapshot.data ?? appointment);
      },
    );
  }
}
