import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class BusinessSetupHeader extends StatelessWidget {
  const BusinessSetupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Column(
      children: [
        Container(
          width: 45.w,
          height: 35.w,
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.verified_user_rounded,
            color: RoleTheme.iconColorFor(
              Icons.verified_user_rounded,
              fallback: palette.primary,
            ),
            size: 26.sp,
          ),
        ),

        SizedBox(height: 5.h),
        Text(
          'Completa estos datos para que la administración revise tu negocio antes de publicarlo en NutriGo.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w600,
            color: palette.mutedText,
            height: 1.28,
          ),
        ),
      ],
    );
  }
}








