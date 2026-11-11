import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/payments/payment_method_model.dart';

class PaymentMethodOptionTile extends StatelessWidget {
  final PaymentType type;
  final IconData icon;
  final String description;
  final VoidCallback onTap;

  const PaymentMethodOptionTile({
    super.key,
    required this.type,
    required this.icon,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: palette.primary.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50.w,
                height: 50.w,
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
                  size: 26.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label,
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.mutedText,
                        fontSize: 11.8.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: palette.primary,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}