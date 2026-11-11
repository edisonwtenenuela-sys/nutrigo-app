import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/nutritionist/controllers/index.dart';

class NutritionistPatientClinicalCard extends StatelessWidget {
  const NutritionistPatientClinicalCard({super.key, required this.data});

  final NutritionistPatientClinicalData data;

  Widget _buildMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required double width,
  }) {
    const palette = RoleTheme.nutritionist;

    return SizedBox(
      width: width,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(17.r),
          border: Border.all(color: color.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            Container(
              width: 31.w,
              height: 31.w,
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: RoleTheme.iconColorFor(icon, fallback: color),
                size: 17.sp,
              ),
            ),
            SizedBox(width: 9.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.mutedText,
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.text,
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoStrip({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    const palette = RoleTheme.nutritionist;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: RoleTheme.iconColorFor(icon, fallback: color),
            size: 17.sp,
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  value,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 11.2.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 10.w) / 2;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Datos registrados por el cliente',
                style: TextStyle(
                  color: palette.text,
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: [
                  _buildMetric(
                    icon: Icons.monitor_weight_rounded,
                    label: 'Peso',
                    value: data.weightText,
                    color: palette.primary,
                    width: itemWidth,
                  ),
                  _buildMetric(
                    icon: Icons.height_rounded,
                    label: 'Estatura',
                    value: data.heightText,
                    color: RoleTheme.iconValidation,
                    width: itemWidth,
                  ),
                  _buildMetric(
                    icon: Icons.cake_rounded,
                    label: 'Edad',
                    value: data.ageText,
                    color: RoleTheme.iconWarning,
                    width: itemWidth,
                  ),
                  _buildMetric(
                    icon: Icons.warning_amber_rounded,
                    label: 'Alergias',
                    value: data.allergiesText,
                    color: RoleTheme.iconDanger,
                    width: itemWidth,
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              _buildInfoStrip(
                icon: Icons.flag_rounded,
                title: 'Objetivo',
                value: data.dietaryGoalText,
                color: RoleTheme.iconInfo,
              ),
              SizedBox(height: 9.h),
              _buildInfoStrip(
                icon: Icons.medical_services_rounded,
                title: 'Condiciones médicas',
                value: data.medicalConditionsText,
                color: palette.primary,
              ),
            ],
          );
        },
      ),
    );
  }
}