import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class PhoneSecurityNote extends StatelessWidget {
  final RolePalette palette;

  const PhoneSecurityNote({
    super.key,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: palette.secondary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(
          color: palette.secondary.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: RoleTheme.iconColorFor(
              Icons.lock_outline_rounded,
              fallback: palette.secondary,
            ),
            size: 19.sp,
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              'Tu número celular será utilizado únicamente para verificar tu identidad y mantener segura tu cuenta.',
              style: TextStyle(
                color: palette.mutedText,
                fontSize: 10.8.sp,
                fontWeight: FontWeight.w600,
                height: 1.28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}