import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class StatisticsLastCalculatedBadge extends StatelessWidget {
  final DateTime lastCalculated;

  const StatisticsLastCalculatedBadge({
    super.key,
    required this.lastCalculated,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final formattedDate = DateFormat(
      'dd MMM yyyy, HH:mm',
      'es_ES',
    ).format(lastCalculated);

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: palette.primary.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(99.r),
          border: Border.all(
            color: palette.primary.withValues(alpha: 0.10),
          ),
        ),
        child: Text(
          'Último cálculo: $formattedDate',
          style: TextStyle(
            color: palette.mutedText,
            fontSize: 10.7.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}