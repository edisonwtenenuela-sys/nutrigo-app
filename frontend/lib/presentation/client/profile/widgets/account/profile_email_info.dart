import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ProfileEmailInfo extends StatelessWidget {
  final String? value;
  final String? email;
  final bool isVerified;
  final String label;
  final IconData icon;
  final String verifiedText;

  const ProfileEmailInfo({
    super.key,
    this.value,
    this.email,
    required this.isVerified,
    required this.label,
    required this.icon,
    this.verifiedText = 'Verificado',
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    final displayValue = (value ?? email ?? '').trim();

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: palette.background.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              size: 17.sp,
              color: RoleTheme.iconColorFor(
                icon,
                fallback: palette.primary,
              ),
            ),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  displayValue.isEmpty
                      ? 'No disponible'
                      : displayValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          if (isVerified) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 9.w,
                vertical: 5.h,
              ),
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                verifiedText,
                style: TextStyle(
                  color: palette.primary,
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}