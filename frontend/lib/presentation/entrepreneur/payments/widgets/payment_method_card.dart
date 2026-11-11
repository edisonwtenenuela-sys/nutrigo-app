import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/payments/payment_method_model.dart';

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethodModel item;
  final String details;
  final IconData icon;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const PaymentMethodCard({
    super.key,
    required this.item,
    required this.details,
    required this.icon,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final isOnline = item.type == PaymentType.online;
    final badgeColor = isOnline ? palette.accent : palette.secondary;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 16.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              icon,
              color: RoleTheme.iconColorFor(
                icon,
                fallback: palette.primary,
              ),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.type.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  details,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 11.6.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 7.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 9.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    isOnline ? 'Stripe' : 'Activo',
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            children: [
              _MiniActionButton(
                icon: Icons.edit_rounded,
                color: palette.primary,
                onTap: onEdit,
              ),
              SizedBox(height: 8.h),
              _MiniActionButton(
                icon: Icons.delete_rounded,
                color: RoleTheme.iconDanger,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _MiniActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Material(
      color: enabled
          ? color.withValues(alpha: 0.08)
          : Colors.grey.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(13.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13.r),
        child: SizedBox(
          width: 34.w,
          height: 34.w,
          child: Icon(
            icon,
            color: enabled ? color : Colors.grey,
            size: 18.sp,
          ),
        ),
      ),
    );
  }
}