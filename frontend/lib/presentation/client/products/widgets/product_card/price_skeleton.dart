import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PriceSkeleton extends StatelessWidget {
  final double width;
  final double height;

  const PriceSkeleton({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: RoleTheme.iconPayments.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(99.r),
      ),
    );
  }
}
