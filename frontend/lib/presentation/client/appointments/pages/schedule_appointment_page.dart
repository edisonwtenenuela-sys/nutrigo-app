import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';
import 'package:emprendedor/features/client/controllers/appointment_controller.dart';
import 'package:emprendedor/features/client/controllers/schedule_appointment_controller.dart';
import 'package:emprendedor/presentation/client/appointments/pages/appointment_detail_page.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/core/nutritionist_appointment_card.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/schedule/appointment_processing_dialog.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/schedule/appointment_section_header.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/state/empty_nutritionists_state.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class ScheduleAppointmentPage extends StatefulWidget {
  const ScheduleAppointmentPage({super.key});

  @override
  State<ScheduleAppointmentPage> createState() =>
      _ScheduleAppointmentPageState();
}

class _ScheduleAppointmentPageState extends State<ScheduleAppointmentPage> {
  late final ScheduleAppointmentController _scheduleController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _scheduleController = ScheduleAppointmentController();
  }

  @override
  void dispose() {
    _scheduleController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppointmentController>().watchNutritionists();
    });
  }

  Future<void> _pickDate(AppointmentController controller) async {
    const palette = RoleTheme.client;
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: ScheduleAppointmentController.initialSchedulingDate(now),
      firstDate: now,
      lastDate: ScheduleAppointmentController.maxSchedulingDate(now),
      selectableDayPredicate: ScheduleAppointmentController.canSelectDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: RoleTheme.iconCalendar,
              onPrimary: Colors.white,
              surface: palette.surface,
              onSurface: palette.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted || selected == null) return;

    final selectedNutritionist = _scheduleController
        .resolveSelectedNutritionist(controller);
    await controller.setSelectedDate(
      selected,
      nutritionist: selectedNutritionist,
    );
  }

  void _showProcessingDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AppointmentProcessingDialog(),
    );
  }

  void _closeProcessingDialogIfNeeded() {
    if (!_scheduleController.isPaymentFlowActive || !mounted) return;

    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) navigator.pop();
  }

  Future<void> _scheduleAppointment(
    AppointmentController controller,
    NutritionistProfileModel nutritionist,
  ) async {
    final result = await _scheduleController.scheduleAppointment(
      controller: controller,
      nutritionist: nutritionist,
      showProcessingDialog: _showProcessingDialog,
      closeProcessingDialog: _closeProcessingDialogIfNeeded,
      onFeedback: (feedback) {
        if (!mounted) return;
        _showFeedback(feedback);
      },
    );

    if (!mounted || result == null) return;

    await _showFeedback(
      ScheduleAppointmentFeedback(
        message: result.message,
        title: 'Cita agendada',
      ),
    );

    if (!mounted) return;
    AppNavigator.replace(
      context,
      AppointmentDetailPage(appointment: result.appointment),
    );
  }

  Future<void> _showFeedback(ScheduleAppointmentFeedback feedback) {
    return showAppMessage(
      context,
      role: AppFeedbackRole.client,
      type: feedback.isError ? AppFeedbackType.error : AppFeedbackType.success,
      title: feedback.isError ? 'No se pudo continuar' : feedback.title,
      message: feedback.message,
    );
  }

  AppBar _buildAppBar(RolePalette palette) {
    return AppBar(
      backgroundColor: palette.background,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: RoleTheme.iconCalendar),
      title: Text(
        _scheduleController.selectedNutritionist == null
            ? 'Agendar cita'
            : 'Confirmar cita',
        style: TextStyle(
          color: palette.text,
          fontWeight: FontWeight.w900,
          fontSize: 19.sp,
        ),
      ),
    );
  }

  Widget _buildLoadingState(RolePalette palette) {
    return const Center(
      child: CircularProgressIndicator(color: RoleTheme.iconCalendar),
    );
  }

  Widget _buildNutritionistList(
    AppointmentController controller,
    RolePalette palette,
  ) {
    return RefreshIndicator(
      color: RoleTheme.iconCalendar,
      onRefresh: () => controller.loadNutritionists(forceRefresh: true),
      child: controller.nutritionists.isEmpty
          ? const EmptyNutritionistsState()
          : ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
              children: [
                AppointmentSectionHeader(
                  totalNutritionists: controller.nutritionists.length,
                ),
                SizedBox(height: 12.h),
                ...controller.nutritionists.map((nutritionist) {
                  return NutritionistAppointmentCard(
                    nutritionist: nutritionist,
                    controller: controller,
                    showBookingForm: false,
                    selectedMode: null,
                    onModeChanged: null,
                    onSelect: () {
                      _scheduleController.selectNutritionist(nutritionist);
                    },
                    onPickDate: () => _pickDate(controller),
                    onPay: () => _scheduleAppointment(controller, nutritionist),
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildSelectedNutritionist(
    AppointmentController controller,
    NutritionistProfileModel nutritionist,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
      children: [
        NutritionistAppointmentCard(
          nutritionist: nutritionist,
          controller: controller,
          showBookingForm: true,
          selectedMode: _scheduleController.selectedMode,
          onModeChanged: _scheduleController.updateMode,
          onBackToList: () {
            controller.clearSchedulingSelection();
            _scheduleController.clearSelectedNutritionist();
          },
          onPickDate: () => _pickDate(controller),
          onPay: () => _scheduleAppointment(controller, nutritionist),
        ),
      ],
    );
  }

  Widget _buildNutritionistsContent(
    AppointmentController controller,
    RolePalette palette,
  ) {
    final selectedNutritionist = _scheduleController
        .resolveSelectedNutritionist(controller);

    if (selectedNutritionist != null) {
      return _buildSelectedNutritionist(controller, selectedNutritionist);
    }

    return _buildNutritionistList(controller, palette);
  }

  Widget _buildPageBody(AppointmentController controller, RolePalette palette) {
    final uiState = ScheduleAppointmentController.resolveUiState(controller);

    return SafeArea(
      top: false,
      child: switch (uiState) {
        ScheduleAppointmentUiState.loading => _buildLoadingState(palette),
        ScheduleAppointmentUiState.content => _buildNutritionistsContent(
          controller,
          palette,
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppointmentController>();
    const palette = RoleTheme.client;

    return ListenableBuilder(
      listenable: _scheduleController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: palette.background,
          appBar: _buildAppBar(palette),
          body: _buildPageBody(controller, palette),
        );
      },
    );
  }
}
