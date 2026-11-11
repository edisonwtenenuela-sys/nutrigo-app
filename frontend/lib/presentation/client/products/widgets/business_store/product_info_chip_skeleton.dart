import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductInfoChipSkeleton extends StatelessWidget {
  final double width;

  const ProductInfoChipSkeleton({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      height: 18.h,
      decoration: BoxDecoration(
        color: RoleTheme.brandChipBackground,
        borderRadius: BorderRadius.circular(99.r),
      ),
    );
  }
}
