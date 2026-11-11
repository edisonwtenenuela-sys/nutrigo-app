import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/core/utils/professional_registry_utils.dart';
import 'package:emprendedor/data/models/admin/nutritionist_verification_request_model.dart';

class NutritionistVerificationRequestCard extends StatelessWidget {
  final NutritionistVerificationRequestModel request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const NutritionistVerificationRequestCard({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  bool _isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 600;
  }

  Widget _buildRejectButton(bool isTablet) {
    return OutlinedButton.icon(
      onPressed: onReject,
      icon: Icon(
        Icons.close_rounded,
        size: isTablet ? 20 : 18.sp,
      ),
      label: Text(
        'Rechazar',
        style: TextStyle(
          fontSize: isTablet ? 13 : 12.5.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: RoleTheme.iconDanger,
        backgroundColor: RoleTheme.iconDanger.withValues(alpha: 0.045),
        side: BorderSide(
          color: RoleTheme.iconDanger.withValues(alpha: 0.28),
        ),
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 14 : 12.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 14.r),
        ),
      ),
    );
  }

  Widget _buildApproveButton(bool isTablet) {
    return ElevatedButton.icon(
      onPressed: onApprove,
      icon: Icon(
        Icons.check_rounded,
        size: isTablet ? 20 : 18.sp,
      ),
      label: Text(
        'Aprobar',
        style: TextStyle(
          fontSize: isTablet ? 13 : 12.5.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: RoleTheme.iconValidation.withValues(alpha: 0.055),
        foregroundColor: RoleTheme.iconValidation,
        side: BorderSide(
          color: RoleTheme.iconValidation.withValues(alpha: 0.22),
        ),
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 14 : 12.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 14.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    const palette = RoleTheme.admin;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(isTablet ? 22 : 20.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.05),
            blurRadius: isTablet ? 20 : 16.r,
            offset: Offset(0, isTablet ? 8 : 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 12 : 10.w),
                decoration: BoxDecoration(
                  color: RoleTheme.iconHealth.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(isTablet ? 14 : 14.r),
                ),
                child: Icon(
                  Icons.health_and_safety_rounded,
                  color: RoleTheme.iconColorFor(
                    Icons.health_and_safety_rounded,
                    fallback: RoleTheme.iconHealth,
                  ),
                  size: isTablet ? 26 : 24.sp,
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name.trim().isEmpty
                          ? 'Nutricionista sin nombre'
                          : request.name.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.text,
                        fontSize: isTablet ? 17 : 15.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      request.email.trim().isEmpty
                          ? 'Correo no registrado'
                          : request.email.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.mutedText,
                        fontSize: isTablet ? 13 : 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 14.h),
          _InfoLine(
            icon: Icons.phone_rounded,
            label: 'Teléfono',
            value: request.phone,
          ),
          _InfoLine(
            icon: Icons.medical_services_rounded,
            label: 'Especialidad',
            value: request.specialty,
          ),
          _InfoLine(
            icon: Icons.badge_rounded,
            label:
            'Registro ${ProfessionalRegistryUtils.registryTypeLabel(request.professionalRegistryType)}',
            value: request.licenseNumber,
          ),
          _InfoLine(
            icon: Icons.description_rounded,
            label: 'Descripción',
            value: request.professionalDescription,
          ),
          if (request.message?.trim().isNotEmpty == true)
            _InfoLine(
              icon: Icons.message_rounded,
              label: 'Mensaje',
              value: request.message!,
            ),
          SizedBox(height: isTablet ? 18 : 16.h),
          Row(
            children: [
              Expanded(child: _buildRejectButton(isTablet)),
              SizedBox(width: isTablet ? 12 : 10.w),
              Expanded(child: _buildApproveButton(isTablet)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  bool _isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 600;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    const palette = RoleTheme.admin;

    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 8 : 7.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: isTablet ? 18 : 17.sp,
            color: RoleTheme.iconColorFor(
              icon,
              fallback: palette.primary,
            ),
          ),
          SizedBox(width: isTablet ? 8 : 7.w),
          Text(
            '$label: ',
            style: TextStyle(
              color: palette.text,
              fontSize: isTablet ? 13 : 12.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? 'No especificado' : value.trim(),
              style: TextStyle(
                color: palette.mutedText,
                fontSize: isTablet ? 13 : 12.sp,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}