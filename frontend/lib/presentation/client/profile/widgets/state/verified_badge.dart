import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class VerifiedBadge extends StatelessWidget {
  final bool isVerified;

  const VerifiedBadge({
    super.key,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color: RoleTheme.brandSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: RoleTheme.brandSoft,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified
                ? Icons.verified_rounded
                : Icons.info_outline_rounded,
            size: 14.sp,
            color: isVerified
                ? RoleTheme.iconValidation
                : RoleTheme.iconInfo,
          ),
          SizedBox(width: 5.w),
          Text(
            isVerified
                ? 'Cliente verificado'
                : 'Perfil por verificar',
            style: TextStyle(
              color: RoleTheme.brandText,
              fontSize: 11.3.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}