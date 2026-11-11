import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';

class NutritionistProductStatusBadge extends StatelessWidget {
  const NutritionistProductStatusBadge({
    super.key,
    this.status = NutritionValidationStatus.pending,
  });

  final NutritionValidationStatus status;

  String get _label {
    return switch (status) {
      NutritionValidationStatus.pending => 'Pendiente',
      NutritionValidationStatus.approved => 'Aprobado',
      NutritionValidationStatus.rejected => 'Rechazado',
    };
  }

  IconData get _icon {
    return switch (status) {
      NutritionValidationStatus.pending => Icons.pending_actions_rounded,
      NutritionValidationStatus.approved => Icons.verified_rounded,
      NutritionValidationStatus.rejected => Icons.cancel_rounded,
    };
  }

  Color get _color {
    return switch (status) {
      NutritionValidationStatus.pending => RoleTheme.iconWarning,
      NutritionValidationStatus.approved => RoleTheme.iconValidation,
      NutritionValidationStatus.rejected => RoleTheme.iconDanger,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon,
            size: 14.sp,
            color: color,
          ),
          SizedBox(width: 4.w),
          Text(
            _label,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}