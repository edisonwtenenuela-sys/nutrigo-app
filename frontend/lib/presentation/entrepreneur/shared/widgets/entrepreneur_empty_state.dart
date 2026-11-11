import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class EntrepreneurEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  final String? infoText;
  final IconData? infoIcon;

  final String? actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;

  const EntrepreneurEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.infoText,
    this.infoIcon,
    this.actionLabel,
    this.actionIcon = Icons.add_rounded,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final hasInfo = infoText?.trim().isNotEmpty ?? false;
    final hasAction = (actionLabel?.trim().isNotEmpty ?? false) &&
        onAction != null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 25.h, 18.w, 22.h),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.04),
            blurRadius: 18.r,
            offset: Offset(0, 9.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 108.w,
            height: 108.w,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 68.w,
                height: 68.w,
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(
                    color: palette.primary.withValues(alpha: 0.12),
                  ),
                ),
                child: Icon(
                  icon,
                  color: RoleTheme.iconColorFor(
                    icon,
                    fallback: palette.primary,
                  ),
                  size: 35.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.text,
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          if (hasInfo) ...[
            SizedBox(height: 18.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: 0.055),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: palette.primary.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    infoIcon ?? Icons.info_outline_rounded,
                    color: RoleTheme.iconColorFor(
                      infoIcon ?? Icons.info_outline_rounded,
                      fallback: palette.primary,
                    ),
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      infoText!.trim(),
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (hasAction) ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: OutlinedButton.icon(
                onPressed: onAction,
                icon: Icon(actionIcon, size: 18.sp),
                label: Text(
                  actionLabel!.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.primary,
                  backgroundColor: palette.primary.withValues(alpha: 0.055),
                  side: BorderSide(
                    color: palette.primary.withValues(alpha: 0.18),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}