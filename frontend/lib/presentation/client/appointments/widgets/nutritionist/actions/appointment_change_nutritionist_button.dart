import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class AppointmentChangeNutritionistButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AppointmentChangeNutritionistButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: RoleTheme.iconHealth.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: RoleTheme.iconHealth.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              size: 15.sp,
              color: RoleTheme.iconHealth,
            ),
            SizedBox(width: 6.w),
            Text(
              'Cambiar nutricionista',
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w900,
                color: RoleTheme.iconHealth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}