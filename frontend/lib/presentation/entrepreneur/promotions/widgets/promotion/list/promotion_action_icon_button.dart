import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PromotionActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const PromotionActionIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(9.r),
      onTap: onTap,
      child: Container(
        width: 27.w,
        height: 27.w,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(color: color.withValues(alpha: 0.10)),
        ),
        child: Icon(icon, color: color, size: 14.5.sp),
      ),
    );
  }
}