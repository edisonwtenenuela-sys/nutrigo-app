import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductIconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const ProductIconAction({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final effectiveColor = isEnabled ? color : Colors.grey.shade400;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30.r),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            color: effectiveColor.withValues(alpha: isEnabled ? 0.09 : 0.06),
            shape: BoxShape.circle,
            border: Border.all(
              color: effectiveColor.withValues(alpha: isEnabled ? 0.08 : 0.04),
            ),
          ),
          child: Icon(icon, color: effectiveColor, size: 16.sp),
        ),
      ),
    );
  }
}








