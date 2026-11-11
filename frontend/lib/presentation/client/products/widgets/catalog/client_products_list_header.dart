import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ClientProductsListHeader extends StatelessWidget {
  final int count;
  final bool isSearching;

  const ClientProductsListHeader({
    super.key,
    required this.count,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Padding(
      padding: EdgeInsets.only(left: 2.w, right: 2.w, bottom: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isSearching ? 'Resultados encontrados' : 'Productos disponibles',
              style: TextStyle(
                color: palette.text,
                fontSize: 15.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(minWidth: 32.w, minHeight: 28.h),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: palette.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: palette.primary,
                fontSize: 11.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
