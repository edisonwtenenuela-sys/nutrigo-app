import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderIconOnlyButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const OrderIconOnlyButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: color.withValues(alpha: 0.18),
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 18.sp,
        ),
      ),
    );
  }
}