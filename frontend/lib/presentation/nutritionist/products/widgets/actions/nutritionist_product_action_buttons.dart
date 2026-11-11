import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistProductActionButtons extends StatelessWidget {
  final bool isDisabled;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const NutritionistProductActionButtons({
    super.key,
    required this.isDisabled,
    required this.onApprove,
    required this.onReject,
  });

  static const palette = RoleTheme.nutritionist;

  Color _rejectBorderColor() {
    return isDisabled
        ? palette.mutedText.withValues(alpha: 0.18)
        : RoleTheme.iconDanger.withValues(alpha: 0.32);
  }

  Color _approveBorderColor() {
    return isDisabled
        ? palette.mutedText.withValues(alpha: 0.18)
        : palette.primary.withValues(alpha: 0.22);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 41.h,
            child: OutlinedButton.icon(
              onPressed: isDisabled ? null : onReject,
              icon: Icon(Icons.close_rounded, size: 17.sp),
              label: Text(
                'Rechazar',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: RoleTheme.iconDanger,
                backgroundColor: RoleTheme.iconDanger.withValues(alpha: 0.04),
                disabledForegroundColor:
                palette.mutedText.withValues(alpha: 0.55),
                side: BorderSide(
                  color: _rejectBorderColor(),
                  width: 1.1.w,
                ),
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: SizedBox(
            height: 41.h,
            child: ElevatedButton.icon(
              onPressed: isDisabled ? null : onApprove,
              icon: Icon(Icons.check_rounded, size: 18.sp),
              label: Text(
                'Aprobar',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.primary.withValues(alpha: 0.05),
                foregroundColor: palette.primary,
                disabledBackgroundColor:
                palette.primary.withValues(alpha: 0.03),
                disabledForegroundColor:
                palette.mutedText.withValues(alpha: 0.55),
                side: BorderSide(
                  color: _approveBorderColor(),
                ),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}