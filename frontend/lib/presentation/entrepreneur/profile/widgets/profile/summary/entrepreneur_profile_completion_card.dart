import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/business_profile_model.dart';

class BusinessProfileCompletionCard extends StatelessWidget {
  final BusinessProfileModel profile;
  final bool hasPaymentMethods;
  final bool hasSocialMedia;

  const BusinessProfileCompletionCard({
    super.key,
    required this.profile,
    required this.hasPaymentMethods,
    required this.hasSocialMedia,
  });

  List<String> _missingFields() {
    return [
      if (profile.name.trim().isEmpty) 'Nombre',
      if ((profile.description ?? '').trim().isEmpty) 'Descripción',
      if ((profile.address ?? '').trim().isEmpty) 'Dirección',
      if ((profile.openingHours ?? '').trim().isEmpty) 'Horarios',
      if ((profile.profileImageUrl ?? '').trim().isEmpty) 'Logo',
      if (!hasPaymentMethods) 'Método de pago',
    ];
  }

  int _calculatePercentage() {
    const int total = 6;
    final completed = total - _missingFields().length;

    return ((completed / total) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;
    final percentage = _calculatePercentage();
    final missingFields = _missingFields();

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 16.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 43.w,
            height: 43.w,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              percentage == 100
                  ? Icons.verified_rounded
                  : Icons.verified_user_rounded,
              color: palette.primary,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Perfil completado',
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w900,
                          color: palette.text,
                        ),
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 15.5.sp,
                        fontWeight: FontWeight.w900,
                        color: palette.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  percentage == 100
                      ? 'Tu negocio está listo para mostrarse a los clientes.'
                      : 'Completa los datos pendientes para mejorar la confianza.',
                  style: TextStyle(
                    fontSize: 11.2.sp,
                    height: 1.25,
                    color: palette.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999.r),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 7.h,
                    backgroundColor: palette.primary.withValues(alpha: 0.10),
                    valueColor: AlwaysStoppedAnimation<Color>(palette.primary),
                  ),
                ),
                if (missingFields.isNotEmpty) ...[
                  SizedBox(height: 9.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: missingFields.map((field) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: palette.primary.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          'Falta: $field',
                          style: TextStyle(
                            color: palette.primary,
                            fontSize: 9.8.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                if (!hasSocialMedia) ...[
                  SizedBox(height: 8.h),
                  Text(
                    'Recomendado: agrega al menos una red social.',
                    style: TextStyle(
                      color: palette.mutedText,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}








