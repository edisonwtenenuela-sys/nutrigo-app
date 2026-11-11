import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class PromotionExpirationTile extends StatelessWidget {
  final DateTime expirationDate;

  const PromotionExpirationTile({super.key, required this.expirationDate});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'dd MMM yyyy',
      'es_ES',
    ).format(expirationDate);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: RoleTheme.iconWarning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: RoleTheme.iconWarning.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule_rounded,
            color: RoleTheme.iconWarning,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Promoción válida hasta el $formattedDate',
              style: TextStyle(
                color: RoleTheme.iconWarning,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
