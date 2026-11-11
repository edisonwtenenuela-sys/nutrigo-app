import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/features/nutritionist/controllers/index.dart';
import 'package:emprendedor/presentation/nutritionist/appointments/widgets/nutritionist_appointment_card.dart';
import 'package:emprendedor/presentation/nutritionist/appointments/widgets/nutritionist_appointments_empty_state.dart';
import 'package:emprendedor/presentation/nutritionist/appointments/widgets/nutritionist_appointments_error_state.dart';
import 'package:emprendedor/presentation/nutritionist/appointments/widgets/nutritionist_appointments_overview.dart';
import 'package:emprendedor/presentation/nutritionist/appointments/widgets/nutritionist_filter_chip_button.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class NutritionistAppointmentsPage extends StatefulWidget {
  const NutritionistAppointmentsPage({super.key});

  @override
  State<NutritionistAppointmentsPage> createState() =>
      _NutritionistAppointmentsPageState();
}

class _NutritionistAppointmentsPageState
    extends State<NutritionistAppointmentsPage> {
  late final NutritionistAppointmentsScreenController _screenController;

  @override
  void initState() {
    super.initState();
    _screenController = NutritionistAppointmentsScreenController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NutritionistAppointmentsController>().initUser();
    });
  }

  @override
  void dispose() {
    _screenController.dispose();
    super.dispose();
  }

  Future<void> _refreshAppointments() async {
    await context.read<NutritionistAppointmentsController>().loadAppointments();
  }

  Future<NutritionistAppointmentStatusResult?> _updateAppointmentStatus(
    NutritionistAppointmentsController controller,
    AppointmentModel appointment,
    AppointmentStatus status,
  ) async {
    final confirmed = await _confirmStatusChange(status);
    if (!confirmed) return null;

    return _screenController.updateAppointmentStatus(
      controller,
      appointment,
      status,
    );
  }

  Future<bool> _confirmStatusChange(AppointmentStatus status) async {
    if (!_screenController.needsConfirmation(status)) return true;

    return showAppConfirm(
      context,
      role: AppFeedbackRole.nutritionist,
      type: AppFeedbackType.warning,
      title: 'Confirmar acción',
      message: _screenController.confirmationMessage(status),
      confirmText: 'Confirmar',
      cancelText: 'Volver',
    );
  }

  Future<void> _showFeedback(NutritionistAppointmentStatusResult result) {
    return showAppMessage(
      context,
      role: AppFeedbackRole.nutritionist,
      type: result.type.toPresentationType(),
      title: result.title,
      message: result.message,
    );
  }

  Widget _buildScrollableState({required Widget child}) {
    return RefreshIndicator(
      onRefresh: _refreshAppointments,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterRow(
    List<({String label, NutritionistAppointmentFilter value})> options,
  ) {
    return Row(
      children: options
          .map(
            (option) => Expanded(
              child: NutritionistFilterChipButton(
                label: option.label,
                selected: _screenController.selectedFilter == option.value,
                onTap: () => _screenController.setFilter(option.value),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildFilters() {
    final options = _screenController.filterOptions;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Column(
        children: [
          _buildFilterRow(options.take(2).toList()),
          SizedBox(height: 7.h),
          _buildFilterRow(options.skip(2).take(2).toList()),
        ],
      ),
    );
  }

  Widget _buildPageBody(
    NutritionistAppointmentsController controller,
    RolePalette palette,
  ) {
    final uiState = _screenController.resolveUiState(controller);

    switch (uiState) {
      case NutritionistAppointmentsUiState.loading:
        return Center(child: CircularProgressIndicator(color: palette.primary));
      case NutritionistAppointmentsUiState.error:
        return _buildScrollableState(
          child: NutritionistAppointmentsErrorState(
            message: controller.errorMessage!,
          ),
        );
      case NutritionistAppointmentsUiState.empty:
        return _buildScrollableState(
          child: const NutritionistAppointmentsEmptyState(),
        );
      case NutritionistAppointmentsUiState.content:
        break;
    }

    final filteredAppointments = _screenController.filteredAppointments(
      controller.appointments,
    );

    return Column(
      children: [
        NutritionistAppointmentsOverview(appointments: controller.appointments),
        SizedBox(height: 10.h),
        _buildFilters(),
        SizedBox(height: 8.h),
        Expanded(
          child: filteredAppointments.isEmpty
              ? _buildScrollableState(
                  child: const NutritionistAppointmentsEmptyState(),
                )
              : RefreshIndicator(
                  onRefresh: _refreshAppointments,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(14.w, 2.h, 14.w, 14.h),
                    itemCount: filteredAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment = filteredAppointments[index];

                      return NutritionistAppointmentCard(
                        appointment: appointment,
                        onUpdateStatus: (status) async {
                          return _updateAppointmentStatus(
                            controller,
                            appointment,
                            status,
                          );
                        },
                        onStatusFeedback: _showFeedback,
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NutritionistAppointmentsController>();
    const palette = RoleTheme.nutritionist;

    return ListenableBuilder(
      listenable: _screenController,
      builder: (context, _) => _buildPageBody(controller, palette),
    );
  }
}
