import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/features/client/controllers/client_appointments_controller.dart';
import 'package:emprendedor/presentation/client/appointments/pages/schedule_appointment_page.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/core/appointment_card.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/core/client_appointments_header.dart';
import 'package:emprendedor/presentation/client/appointments/widgets/state/empty_appointments_state.dart';

class ClientAppointmentsPage extends StatefulWidget {
  const ClientAppointmentsPage({super.key});

  @override
  State<ClientAppointmentsPage> createState() => _ClientAppointmentsPageState();
}

class _ClientAppointmentsPageState extends State<ClientAppointmentsPage> {
  final ClientAppointmentsController _controller =
      ClientAppointmentsController();
  _AppointmentFilter _selectedFilter = _AppointmentFilter.all;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  AppBar _buildAppBar(RolePalette palette) {
    return AppBar(
      backgroundColor: palette.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Mis citas',
        style: TextStyle(
          color: palette.text,
          fontWeight: FontWeight.w900,
          fontSize: 19.sp,
        ),
      ),
    );
  }

  Widget _buildNotAuthenticatedState(RolePalette palette) {
    return Scaffold(
      backgroundColor: palette.background,
      body: Center(
        child: Text(
          'No hay usuario autenticado.',
          style: TextStyle(
            color: palette.text,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(RolePalette palette) {
    return const Center(
      child: CircularProgressIndicator(color: RoleTheme.iconCalendar),
    );
  }

  Widget _buildEmptyState(RolePalette palette) {
    return RefreshIndicator(
      color: RoleTheme.iconCalendar,
      onRefresh: _controller.refreshAppointments,
      child: EmptyAppointmentsState(
        onSchedule: () {
          AppNavigator.push(context, const ScheduleAppointmentPage());
        },
      ),
    );
  }

  Widget _buildAppointmentsList(
    List<AppointmentModel> appointments,
    RolePalette palette,
  ) {
    final summary = _controller.buildSummary(appointments);
    final filteredAppointments = _filterAppointments(appointments);

    return RefreshIndicator(
      color: RoleTheme.iconCalendar,
      onRefresh: _controller.refreshAppointments,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 22.h),
        itemCount: filteredAppointments.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClientAppointmentsHeader(
                  total: summary.total,
                  pending: summary.pending,
                  completed: summary.completed,
                ),
                SizedBox(height: 12.h),
                _buildFilterBar(appointments),
                if (filteredAppointments.isEmpty)
                  _buildFilteredEmptyState(palette),
              ],
            );
          }

          return AppointmentCard(appointment: filteredAppointments[index - 1]);
        },
      ),
    );
  }

  List<AppointmentModel> _filterAppointments(
    List<AppointmentModel> appointments,
  ) {
    return appointments.where((appointment) {
      return switch (_selectedFilter) {
        _AppointmentFilter.all => true,
        _AppointmentFilter.pending =>
          appointment.status == AppointmentStatus.pending,
        _AppointmentFilter.confirmed =>
          appointment.status == AppointmentStatus.confirmed,
        _AppointmentFilter.completed =>
          appointment.status == AppointmentStatus.completed,
        _AppointmentFilter.cancelled =>
          appointment.status == AppointmentStatus.cancelled ||
              appointment.status == AppointmentStatus.noShow,
      };
    }).toList();
  }

  Widget _buildFilterBar(List<AppointmentModel> appointments) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _AppointmentFilter.values.map((filter) {
            final selected = _selectedFilter == filter;
            final count = _filterCount(appointments, filter);
            return Padding(
              padding: EdgeInsets.only(right: 7.w),
              child: _AppointmentFilterChip(
                label: filter.label,
                count: count,
                icon: filter.icon,
                color: filter.color,
                selected: selected,
                onTap: () => setState(() => _selectedFilter = filter),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  int _filterCount(
    List<AppointmentModel> appointments,
    _AppointmentFilter filter,
  ) {
    return appointments.where((appointment) {
      return switch (filter) {
        _AppointmentFilter.all => true,
        _AppointmentFilter.pending =>
          appointment.status == AppointmentStatus.pending,
        _AppointmentFilter.confirmed =>
          appointment.status == AppointmentStatus.confirmed,
        _AppointmentFilter.completed =>
          appointment.status == AppointmentStatus.completed,
        _AppointmentFilter.cancelled =>
          appointment.status == AppointmentStatus.cancelled ||
              appointment.status == AppointmentStatus.noShow,
      };
    }).length;
  }

  Widget _buildFilteredEmptyState(RolePalette palette) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 18.h),
      padding: EdgeInsets.fromLTRB(22.w, 28.h, 22.w, 30.h),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: RoleTheme.iconCalendar.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            color: RoleTheme.iconCalendar,
            size: 34.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            'Sin citas en este filtro',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.text,
              fontSize: 15.5.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Prueba seleccionando otro estado.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageBody(String userId, RolePalette palette) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return StreamBuilder<List<AppointmentModel>>(
          stream: _controller.appointmentsStream(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState(palette);
            }

            final appointments = snapshot.data ?? [];

            if (appointments.isEmpty) {
              return _buildEmptyState(palette);
            }

            return _buildAppointmentsList(appointments, palette);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _controller.currentUserId;
    const palette = RoleTheme.client;

    if (userId == null) {
      return _buildNotAuthenticatedState(palette);
    }

    return Scaffold(
      backgroundColor: palette.background,
      appBar: _buildAppBar(palette),
      body: _buildPageBody(userId, palette),
    );
  }
}

enum _AppointmentFilter {
  all,
  pending,
  confirmed,
  completed,
  cancelled;

  String get label {
    return switch (this) {
      _AppointmentFilter.all => 'Todas',
      _AppointmentFilter.pending => 'Pendientes',
      _AppointmentFilter.confirmed => 'Confirmadas',
      _AppointmentFilter.completed => 'Completadas',
      _AppointmentFilter.cancelled => 'Canceladas',
    };
  }

  IconData get icon {
    return switch (this) {
      _AppointmentFilter.all => Icons.event_note_rounded,
      _AppointmentFilter.pending => Icons.schedule_rounded,
      _AppointmentFilter.confirmed => Icons.verified_rounded,
      _AppointmentFilter.completed => Icons.check_circle_rounded,
      _AppointmentFilter.cancelled => Icons.cancel_rounded,
    };
  }

  Color get color {
    return switch (this) {
      _AppointmentFilter.all => RoleTheme.iconCalendar,
      _AppointmentFilter.pending => RoleTheme.iconWarning,
      _AppointmentFilter.confirmed => RoleTheme.iconInfo,
      _AppointmentFilter.completed => RoleTheme.iconValidation,
      _AppointmentFilter.cancelled => RoleTheme.iconDanger,
    };
  }
}

class _AppointmentFilterChip extends StatelessWidget {
  const _AppointmentFilterChip({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : color;
    final background = selected ? color : RoleTheme.client.surface;

    return InkWell(
      borderRadius: BorderRadius.circular(999.r),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: color.withValues(alpha: 0.20)),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.14),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13.sp, color: foreground),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(width: 5.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.20)
                    : color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: foreground,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
