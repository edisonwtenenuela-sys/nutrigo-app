import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ClientProfilePrivacyNote extends StatelessWidget {
  const ClientProfilePrivacyNote({super.key});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: palette.secondary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: palette.secondary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_rounded,
            color: RoleTheme.iconColorFor(
              Icons.lock_rounded,
              fallback: palette.primary,
            ),
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Tus datos se utilizan únicamente para gestionar pedidos, citas y ofrecer recomendaciones personalizadas dentro de la aplicación.',
              style: TextStyle(
                color: palette.text,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}