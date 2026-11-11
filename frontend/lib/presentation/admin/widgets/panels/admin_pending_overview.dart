import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/admin/admin_verification_request_model.dart';
import 'package:emprendedor/data/models/admin/nutritionist_verification_request_model.dart';

class AdminPendingOverview extends StatelessWidget {
  final Stream<List<AdminVerificationRequestModel>> entrepreneurStream;
  final Stream<List<NutritionistVerificationRequestModel>> nutritionistStream;

  const AdminPendingOverview({
    super.key,
    required this.entrepreneurStream,
    required this.nutritionistStream,
  });

  Widget _buildMetricCard<T>({
    required Stream<List<T>> stream,
    required IconData icon,
    required String label,
  }) {
    return _PendingMetricCard<T>(stream: stream, icon: icon, label: label);
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.admin;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.05),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard<AdminVerificationRequestModel>(
              stream: entrepreneurStream,
              icon: Icons.storefront_rounded,
              label: 'Emprendedores',
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _buildMetricCard<NutritionistVerificationRequestModel>(
              stream: nutritionistStream,
              icon: Icons.health_and_safety_rounded,
              label: 'Nutricionistas',
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingMetricCard<T> extends StatelessWidget {
  final Stream<List<T>> stream;
  final IconData icon;
  final String label;

  const _PendingMetricCard({
    required this.stream,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.admin;

    return StreamBuilder<List<T>>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        final iconColor = RoleTheme.iconColorFor(
          icon,
          fallback: palette.primary,
        );

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
          ),
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, color: iconColor, size: 20.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          color: palette.mutedText,
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
