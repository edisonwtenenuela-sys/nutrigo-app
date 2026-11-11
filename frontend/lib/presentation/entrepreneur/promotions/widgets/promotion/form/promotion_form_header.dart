import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class PromotionFormHeader extends StatelessWidget {
  final bool isEditing;

  const PromotionFormHeader({super.key, required this.isEditing});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final icon = isEditing ? Icons.edit_note_rounded : Icons.campaign_rounded;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(13.w, 12.h, 13.w, 12.h),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.06),
            blurRadius: 13.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(11.r),
              border: Border.all(
                color: palette.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Icon(
              icon,
              color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
              size: 23.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Actualiza tu oferta' : 'Nueva promoción',
                  maxLines: 2,
                  style: TextStyle(
                    color: palette.primary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Configura el descuento, productos y vigencia.',
                  maxLines: 2,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 10.2.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
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
