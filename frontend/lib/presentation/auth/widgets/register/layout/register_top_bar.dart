import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class RegisterTopBar extends StatelessWidget {
  final RolePalette palette;
  final bool isLoading;
  final VoidCallback onBack;

  const RegisterTopBar({
    super.key,
    required this.palette,
    required this.isLoading,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 3.h, 12.w, 5.h),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: palette.primary.withValues(alpha: 0.10),
              ),
            ),
            child: IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: isLoading ? null : onBack,
              icon: Icon(
                Icons.arrow_back_rounded,
                color: RoleTheme.iconColorFor(
                  Icons.arrow_back_rounded,
                  fallback: palette.text,
                ),
                size: 22.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Crear cuenta',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.text,
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: 48.w),
        ],
      ),
    );
  }
}