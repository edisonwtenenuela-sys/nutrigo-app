import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';
import 'package:emprendedor/presentation/nutritionist/patients/pages/nutritionist_patient_detail_page.dart';

class NutritionistPatientCard extends StatelessWidget {
  final Map<String, dynamic> patient;

  const NutritionistPatientCard({super.key, required this.patient});

  Color _statusColor(AppointmentStatus? status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return RoleTheme.nutritionist.primary;
      case AppointmentStatus.completed:
        return RoleTheme.iconValidation;
      case AppointmentStatus.cancelled:
        return RoleTheme.iconDanger;
      case AppointmentStatus.pending:
        return RoleTheme.iconWarning;
      case AppointmentStatus.noShow:
        return Colors.grey;
      default:
        return RoleTheme.nutritionist.primary;
    }
  }

  String _statusText(AppointmentStatus? status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return 'Paciente activo';
      case AppointmentStatus.completed:
        return 'Atendido';
      case AppointmentStatus.pending:
        return 'Pendiente';
      case AppointmentStatus.cancelled:
        return 'Cancelado';
      case AppointmentStatus.noShow:
        return 'No asistió';
      default:
        return 'Registrado';
    }
  }

  _PatientCardData _resolveData() {
    final name = patient['name']?.toString() ?? 'Paciente';
    final imageUrl = patient['profileImageUrl']?.toString();
    final lastDate = patient['lastDate'];
    final status = patient['status'] as AppointmentStatus?;
    final appointmentCount = patient['appointmentCount'] as int? ?? 1;
    final completedCount = patient['completedCount'] as int? ?? 0;

    return _PatientCardData(
      name: name,
      imageUrl: imageUrl,
      status: status,
      statusColor: _statusColor(status),
      appointmentCount: appointmentCount,
      completedCount: completedCount,
      lastDateText: lastDate != null
          ? DateFormat('dd MMM yyyy', 'es').format(lastDate.toDate())
          : 'Sin fecha registrada',
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;
    final data = _resolveData();

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(24.r),
          onTap: () {
            AppNavigator.push(
              context,
              NutritionistPatientDetailPage(patient: patient),
            );
          },
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: palette.primary.withValues(alpha: 0.10),
              ),
              boxShadow: [
                BoxShadow(
                  color: palette.shadow,
                  blurRadius: 16.r,
                  offset: Offset(0, 7.h),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _PatientAvatar(imageUrl: data.imageUrl),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15.5.sp,
                              fontWeight: FontWeight.w900,
                              color: palette.text,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month_rounded,
                                color: RoleTheme.iconColorFor(
                                  Icons.calendar_month_rounded,
                                  fallback: palette.primary,
                                ),
                                size: 15.sp,
                              ),
                              SizedBox(width: 5.w),
                              Expanded(
                                child: Text(
                                  'Última cita: ${data.lastDateText}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5.sp,
                                    color: palette.mutedText,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: palette.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(13.r),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 15.sp,
                        color: palette.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 13.h),
                Row(
                  children: [
                    _PatientChip(
                      icon: Icons.health_and_safety_rounded,
                      label: _statusText(data.status),
                      color: data.statusColor,
                    ),
                    SizedBox(width: 7.w),
                    _PatientChip(
                      icon: Icons.event_note_rounded,
                      label: '${data.appointmentCount} citas',
                      color: palette.primary,
                    ),
                    SizedBox(width: 7.w),
                    _PatientChip(
                      icon: Icons.check_circle_rounded,
                      label: '${data.completedCount} atendidas',
                      color: RoleTheme.iconValidation,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PatientCardData {
  final String name;
  final String? imageUrl;
  final AppointmentStatus? status;
  final Color statusColor;
  final int appointmentCount;
  final int completedCount;
  final String lastDateText;

  const _PatientCardData({
    required this.name,
    required this.imageUrl,
    required this.status,
    required this.statusColor,
    required this.appointmentCount,
    required this.completedCount,
    required this.lastDateText,
  });
}

class _PatientAvatar extends StatelessWidget {
  final String? imageUrl;

  const _PatientAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    final cleanUrl = imageUrl?.trim();
    final hasImage = cleanUrl != null && cleanUrl.isNotEmpty;

    return Container(
      width: 48.r,
      height: 48.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.primary.withValues(alpha: 0.08),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: cleanUrl,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 320),
              placeholder: (_, _) => const SizedBox.expand(),
              errorWidget: (_, _, _) => const _AvatarPlaceholder(),
            )
          : const _AvatarPlaceholder(),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Center(
      child: Icon(
        Icons.person_rounded,
        color: RoleTheme.iconColorFor(
          Icons.person_rounded,
          fallback: palette.primary,
        ),
        size: 24.sp,
      ),
    );
  }
}

class _PatientChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PatientChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(color: color.withValues(alpha: 0.14)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: RoleTheme.iconColorFor(icon, fallback: color),
              size: 12.sp,
            ),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
