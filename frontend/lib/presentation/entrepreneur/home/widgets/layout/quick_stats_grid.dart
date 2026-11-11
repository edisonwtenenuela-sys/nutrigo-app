import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuickStatsGrid extends StatelessWidget {
  final List<Widget> children;

  const QuickStatsGrid({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 2,
        mainAxisSpacing: isTablet ? 12 : 10.h,
        crossAxisSpacing: isTablet ? 12 : 10.w,
        childAspectRatio: isTablet ? 1.80 : 1.42,
      ),
      children: children,
    );
  }
}