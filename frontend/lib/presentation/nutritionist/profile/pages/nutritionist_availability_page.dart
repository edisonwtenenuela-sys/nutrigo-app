import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_availability_model.dart';
import 'package:emprendedor/features/nutritionist/controllers/nutritionist_availability_controller.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class NutritionistAvailabilityPage extends StatefulWidget {
  const NutritionistAvailabilityPage({super.key});

  @override
  State<NutritionistAvailabilityPage> createState() =>
      _NutritionistAvailabilityPageState();
}

class _NutritionistAvailabilityPageState
    extends State<NutritionistAvailabilityPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<NutritionistAvailabilityController>().loadAvailability();
    });
  }

  Future<void> _save(NutritionistAvailabilityController controller) async {
    final saved = await controller.saveAvailability();

    if (!mounted) return;

    final error = controller.errorMessage;
    final success = controller.successMessage;

    if (saved && success != null) {
      await showAppMessage(
        context,
        role: AppFeedbackRole.nutritionist,
        type: AppFeedbackType.success,
        title: 'Horarios guardados',
        message: success,
      );
      return;
    }

    if (error != null) {
      await showAppMessage(
        context,
        role: AppFeedbackRole.nutritionist,
        type: AppFeedbackType.error,
        title: 'No se pudo guardar',
        message: error,
      );
    }
  }

  Widget _buildHeader(RolePalette palette) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: palette.headerGradient,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Icon(
              Icons.schedule_rounded,
              color: RoleTheme.iconColorFor(
                Icons.schedule_rounded,
                fallback: palette.surface,
              ),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Horarios de atención',
                  style: TextStyle(
                    color: palette.surface,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Define cuándo pueden agendarte una cita.',
                  style: TextStyle(
                    color: palette.surface.withValues(alpha: 0.86),
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelector(
      NutritionistAvailabilityController controller,
      NutritionistAvailabilityModel availability,
      RolePalette palette,
      ) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
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
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(
              Icons.timelapse_rounded,
              color: RoleTheme.iconColorFor(
                Icons.timelapse_rounded,
                fallback: palette.primary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Duración por cita',
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Cada bloque disponible usará este tiempo.',
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: availability.slotDurationMinutes,
              borderRadius: BorderRadius.circular(14.r),
              dropdownColor: palette.surface,
              style: TextStyle(
                color: palette.text,
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
              ),
              items: NutritionistAvailabilityController.slotDurationOptions
                  .map(
                    (duration) => DropdownMenuItem<int>(
                  value: duration,
                  child: Text('$duration min'),
                ),
              )
                  .toList(),
              onChanged: controller.isSaving
                  ? null
                  : (value) {
                if (value != null) controller.updateSlotDuration(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(
      NutritionistAvailabilityController controller,
      String dayKey,
      NutritionistAvailabilityDay day,
      RolePalette palette,
      ) {
    final label = NutritionistAvailabilityModel.weekdayLabels[dayKey] ?? dayKey;

    return Container(
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: day.enabled
              ? palette.primary.withValues(alpha: 0.28)
              : palette.primary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 13.2.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Switch.adaptive(
                value: day.enabled,
                activeThumbColor: palette.primary,
                activeTrackColor: palette.primary.withValues(alpha: 0.25),
                onChanged: controller.isSaving
                    ? null
                    : (value) => controller.toggleDay(dayKey, value),
              ),
            ],
          ),
          if (day.enabled) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: _TimeDropdown(
                    label: 'Desde',
                    value: day.startTime,
                    palette: palette,
                    onChanged: controller.isSaving
                        ? null
                        : (value) => controller.updateStartTime(dayKey, value),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _TimeDropdown(
                    label: 'Hasta',
                    value: day.endTime,
                    palette: palette,
                    onChanged: controller.isSaving
                        ? null
                        : (value) => controller.updateEndTime(dayKey, value),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveButton(
      NutritionistAvailabilityController controller,
      RolePalette palette,
      ) {
    return SizedBox(
      height: 48.h,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.surface,
          disabledBackgroundColor: palette.primary.withValues(alpha: 0.35),
          disabledForegroundColor: palette.surface.withValues(alpha: 0.72),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        onPressed: controller.isSaving ? null : () => _save(controller),
        icon: controller.isSaving
            ? SizedBox(
          width: 16.w,
          height: 16.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: palette.surface,
          ),
        )
            : Icon(
          Icons.save_rounded,
          color: RoleTheme.iconColorFor(
            Icons.save_rounded,
            fallback: palette.surface,
          ),
        ),
        label: Text(
          controller.isSaving ? 'Guardando...' : 'Guardar horarios',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;
    final controller = context.watch<NutritionistAvailabilityController>();
    final availability = controller.availability;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        surfaceTintColor: palette.background,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: palette.text),
        title: Text(
          'Disponibilidad',
          style: TextStyle(
            color: palette.text,
            fontWeight: FontWeight.w900,
            fontSize: 19.sp,
          ),
        ),
      ),
      body: controller.isLoading || availability == null
          ? Center(
        child: CircularProgressIndicator(color: palette.primary),
      )
          : SafeArea(
        top: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
          children: [
            _buildHeader(palette),
            SizedBox(height: 12.h),
            _buildDurationSelector(controller, availability, palette),
            SizedBox(height: 12.h),
            ...NutritionistAvailabilityModel.weekdayKeys.map((dayKey) {
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _buildDayCard(
                  controller,
                  dayKey,
                  availability.days[dayKey] ??
                      const NutritionistAvailabilityDay.disabled(),
                  palette,
                ),
              );
            }),
            SizedBox(height: 8.h),
            _buildSaveButton(controller, palette),
          ],
        ),
      ),
    );
  }
}

class _TimeDropdown extends StatelessWidget {
  const _TimeDropdown({
    required this.label,
    required this.value,
    required this.palette,
    required this.onChanged,
  });

  final String label;
  final String value;
  final RolePalette palette;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              borderRadius: BorderRadius.circular(14.r),
              dropdownColor: palette.surface,
              style: TextStyle(
                color: palette.text,
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
              ),
              items: NutritionistAvailabilityController.timeOptions
                  .map(
                    (time) => DropdownMenuItem<String>(
                  value: time,
                  child: Text(time),
                ),
              )
                  .toList(),
              onChanged: onChanged == null
                  ? null
                  : (value) {
                if (value != null) onChanged!(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}