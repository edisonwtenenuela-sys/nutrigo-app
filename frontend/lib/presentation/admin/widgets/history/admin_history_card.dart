import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class AdminHistoryLine {
  final IconData icon;
  final String label;
  final String value;

  const AdminHistoryLine({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class AdminHistoryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String status;
  final DateTime createdAt;
  final List<AdminHistoryLine> lines;

  const AdminHistoryCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.createdAt,
    required this.lines,
  });

  bool get _isApproved => status == 'approved';

  Widget _buildHeader(
    RolePalette palette,
    Color statusColor,
    String statusText,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(icon, color: iconColor, size: 26.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.trim().isEmpty ? 'Sin nombre' : title.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w900,
                  color: palette.text,
                ),
              ),
              SizedBox(height: 3.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  subtitle.trim().isEmpty
                      ? 'Sin correo registrado'
                      : subtitle.trim(),
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 11.8.sp,
                    color: palette.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 1.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w900,
                color: statusColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreatedAt(RolePalette palette) {
    return Row(
      children: [
        Icon(
          Icons.calendar_month_rounded,
          size: 15.sp,
          color: RoleTheme.iconCalendar,
        ),
        SizedBox(width: 6.w),
        Text(
          'Solicitud: ${DateFormat('dd/MM/yyyy').format(createdAt)}',
          style: TextStyle(
            fontSize: 11.5.sp,
            color: palette.mutedText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.admin;
    final statusColor = _isApproved
        ? RoleTheme.iconValidation
        : RoleTheme.iconDanger;
    final statusText = _isApproved ? 'Aprobado' : 'Rechazado';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.045),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(palette, statusColor, statusText),

          SizedBox(height: 12.h),

          ...lines.map((line) => _InfoLine(line: line)),

          SizedBox(height: 6.h),
          _buildCreatedAt(palette),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final AdminHistoryLine line;

  const _InfoLine({required this.line});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.admin;

    return Padding(
      padding: EdgeInsets.only(bottom: 7.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            line.icon,
            size: 16.sp,
            color: RoleTheme.iconColorFor(line.icon, fallback: palette.primary),
          ),
          SizedBox(width: 7.w),
          Text(
            '${line.label}: ',
            style: TextStyle(
              fontSize: 11.8.sp,
              fontWeight: FontWeight.w900,
              color: palette.text,
            ),
          ),
          Expanded(
            child: Text(
              line.value.trim().isEmpty ? 'No especificado' : line.value.trim(),
              style: TextStyle(
                fontSize: 11.8.sp,
                color: palette.mutedText,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
