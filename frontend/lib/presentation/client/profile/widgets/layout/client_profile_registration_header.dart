import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/auth/controllers/auth_session_controller.dart';

class ClientProfileRegistrationHeader extends StatelessWidget {
  ClientProfileRegistrationHeader({super.key});

  final AuthSessionController _sessionController = AuthSessionController();

  @override
  Widget build(BuildContext context) {
    final email = _sessionController.currentSnapshot()?.email?.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 15.h),
      decoration: BoxDecoration(
        color: RoleTheme.brandBadgeBackground,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: RoleTheme.brandSoft),
        boxShadow: [
          BoxShadow(
            color: RoleTheme.brandPrimary.withValues(alpha: 0.07),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: RoleTheme.brandSoft),
              borderRadius: BorderRadius.circular(17.r),
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: RoleTheme.iconHealth,
              size: 27.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configura tu cuenta',
                  style: TextStyle(
                    color: RoleTheme.brandText,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  email == null || email.isEmpty
                      ? 'Completa tus datos para comenzar a comprar saludable.'
                      : '$email\nCorreo vinculado a tu cuenta.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RoleTheme.brandMutedText,
                    fontSize: 11.5.sp,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}