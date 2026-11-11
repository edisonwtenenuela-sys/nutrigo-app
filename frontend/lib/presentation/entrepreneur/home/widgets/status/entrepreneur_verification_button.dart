import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class BusinessVerificationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool enabled;
  final String label;
  final IconData icon;

  const BusinessVerificationButton({
    super.key,
    required this.onPressed,
    this.enabled = true,
    this.label = 'Solicitar verificación',
    this.icon = Icons.send_rounded,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return SizedBox(
      width: double.infinity,
      height: 42.h,
      child: OutlinedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(
          icon,
          size: 16.sp,
        ),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: enabled
              ? palette.primary
              : Colors.grey.shade600,
          backgroundColor: enabled
              ? palette.primary.withValues(alpha: 0.055)
              : Colors.grey.shade200,
          side: BorderSide(
            color: enabled
                ? palette.primary.withValues(alpha: 0.18)
                : Colors.grey.shade300,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}