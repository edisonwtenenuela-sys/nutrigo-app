import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderItemIcon extends StatelessWidget {
  final Color color;

  const OrderItemIcon({
    super.key,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Icon(
        Icons.receipt_long_rounded,
        color: color,
        size: 21.sp,
      ),
    );
  }
}