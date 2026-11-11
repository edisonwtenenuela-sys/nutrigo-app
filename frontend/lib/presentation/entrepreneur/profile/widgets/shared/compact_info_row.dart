import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class CompactInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? content;

  const CompactInfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  void _showFullContent(BuildContext context, String title, String content) {
    showAppMessage(
      context,
      role: AppFeedbackRole.entrepreneur,
      type: AppFeedbackType.info,
      title: title,
      message: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;
    final hasContent = content != null && content!.trim().isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: hasContent
          ? () => _showFullContent(context, title, content!.trim())
          : null,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 3.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
                size: 19.sp,
              ),
            ),
            SizedBox(width: 11.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w900,
                      color: palette.text,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    hasContent ? content!.trim() : 'No especificado',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.8.sp,
                      color: hasContent ? palette.mutedText : palette.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (hasContent)
              Padding(
                padding: EdgeInsets.only(left: 6.w),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.sp,
                  color: palette.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}








