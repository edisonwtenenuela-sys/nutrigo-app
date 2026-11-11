import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class OrderInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  final int maxLines;

  const OrderInfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.color,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;
    final textColor = color ?? palette.mutedText;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 14.sp,
          color: textColor,
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
        ),
      ],
    );
  }
}