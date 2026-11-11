import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';

class NutritionistHeader extends StatelessWidget {
  final NutritionistProfileModel nutritionist;

  const NutritionistHeader({
    super.key,
    required this.nutritionist,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    final hasImage =
        nutritionist.profileImageUrl != null &&
            nutritionist.profileImageUrl!.trim().isNotEmpty;

    final isVerified = nutritionist.isVerified;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 28.r,
          backgroundColor: RoleTheme.brandChipBackground,
          backgroundImage: hasImage
              ? NetworkImage(nutritionist.profileImageUrl!)
              : null,
          child: hasImage
              ? null
              : Icon(
            Icons.person_rounded,
            size: 28.sp,
            color: RoleTheme.iconColorFor(
              Icons.person_rounded,
              fallback: RoleTheme.iconProfile,
            ),
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nutritionist.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                nutritionist.specialty?.isNotEmpty == true
                    ? nutritionist.specialty!
                    : 'Nutrición profesional',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.mutedText,
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 6.h,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: RoleTheme.iconCalendar.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      nutritionist.consultationMode.label,
                      style: TextStyle(
                        color: RoleTheme.iconCalendar,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                  if (isVerified)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: RoleTheme.iconValidation.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: RoleTheme.iconColorFor(
                              Icons.verified_rounded,
                              fallback: RoleTheme.iconValidation,
                            ),
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Perfil verificado',
                            style: TextStyle(
                              color: RoleTheme.iconValidation,
                              fontWeight: FontWeight.w700,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}