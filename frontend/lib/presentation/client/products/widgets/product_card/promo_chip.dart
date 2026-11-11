import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PromoChip extends StatelessWidget {
  final String label;

  const PromoChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: RoleTheme.iconPromotion.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: RoleTheme.iconPromotion,
          fontSize: 8.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
