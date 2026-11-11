import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class CartPanelIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const CartPanelIcon({
    super.key,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final semanticIconColor = RoleTheme.iconColorFor(
      icon,
      fallback: color,
    );

    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: semanticIconColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        icon,
        color: semanticIconColor,
        size: 21.sp,
      ),
    );
  }
}