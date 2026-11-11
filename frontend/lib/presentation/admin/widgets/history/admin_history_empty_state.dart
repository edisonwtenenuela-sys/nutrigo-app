import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class AdminHistoryEmptyState extends StatelessWidget {
  final bool isApproved;
  final String typeText;

  const AdminHistoryEmptyState({
    super.key,
    required this.isApproved,
    required this.typeText,
  });

  String get _titleText {
    return isApproved
        ? 'No hay $typeText aprobados'
        : 'No hay $typeText rechazados';
  }

  IconData get _stateIcon {
    return isApproved ? Icons.check_circle_rounded : Icons.cancel_rounded;
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.admin;
    final color = isApproved
        ? RoleTheme.iconValidation
        : RoleTheme.iconDanger;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(26.r),
            border: Border.all(color: palette.primary.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: palette.primary.withValues(alpha: 0.045),
                blurRadius: 18.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(_stateIcon, color: color, size: 40.sp),
              ),
              SizedBox(height: 16.h),
              Text(
                _titleText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                  color: palette.text,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Cuando existan solicitudes con este estado, aparecerán aquí.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  color: palette.mutedText,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}








