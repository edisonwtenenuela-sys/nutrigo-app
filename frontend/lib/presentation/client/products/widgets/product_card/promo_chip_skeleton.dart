import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PromoChipSkeleton extends StatelessWidget {
  const PromoChipSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62.w,
      height: 16.h,
      decoration: BoxDecoration(
        color: RoleTheme.iconPromotion.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30.r),
      ),
    );
  }
}
