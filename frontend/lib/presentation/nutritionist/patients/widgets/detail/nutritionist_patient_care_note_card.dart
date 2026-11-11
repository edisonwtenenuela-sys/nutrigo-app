import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistPatientCareNoteCard extends StatelessWidget {
  final Color statusColor;
  final String statusText;

  const NutritionistPatientCareNoteCard({
    super.key,
    required this.statusColor,
    required this.statusText,
  });

  static const _title = 'Recomendación de seguimiento';

  String _message() {
    return 'Estado actual: $statusText. Revisa sus citas y registra recomendaciones cuando corresponda.';
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.09),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.assignment_turned_in_rounded,
              color: statusColor,
              size: 21.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  _message(),
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}