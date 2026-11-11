import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class NutritionistDescriptionPreview extends StatelessWidget {
  final String nutritionistName;
  final String description;
  final int maxLines;

  const NutritionistDescriptionPreview({
    super.key,
    required this.nutritionistName,
    required this.description,
    required this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15.r),
        onTap: () => _showFullDescription(context),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: palette.background,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: RoleTheme.iconHealth.withValues(alpha: 0.07),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.mutedText,
                  height: 1.25,
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 7.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.open_in_full_rounded,
                    color: RoleTheme.iconInfo,
                    size: 12.sp,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    'Ver información completa',
                    style: TextStyle(
                      color: RoleTheme.iconInfo,
                      fontSize: 10.3.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullDescription(BuildContext context) {
    const palette = RoleTheme.client;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final maxHeight = MediaQuery.sizeOf(context).height * 0.58;

        return SafeArea(
          top: false,
          child: Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            margin: EdgeInsets.all(14.w),
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 18.h),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: RoleTheme.iconHealth.withValues(alpha: 0.10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24.r,
                  offset: Offset(0, 12.h),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: RoleTheme.iconHealth.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: RoleTheme.iconHealth.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(13.r),
                      ),
                      child: Icon(
                        Icons.article_rounded,
                        color: RoleTheme.iconColorFor(
                          Icons.article_rounded,
                          fallback: RoleTheme.iconInfo,
                        ),
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Descripción profesional',
                            style: TextStyle(
                              color: palette.text,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            nutritionistName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.mutedText,
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: RoleTheme.iconColorFor(
                          Icons.close_rounded,
                          fallback: RoleTheme.iconDanger,
                        ),
                        size: 21.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      description,
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 12.8.sp,
                        height: 1.38,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}