import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/shared/widgets/smooth_profile_avatar.dart';
import 'package:emprendedor/presentation/client/profile/widgets/state/verified_badge.dart';

class ClientProfileHeaderCard extends StatelessWidget {
  final String name;
  final String goal;
  final String? imageUrl;
  final bool isVerified;
  final bool isUploadingImage;
  final VoidCallback onChangePhoto;

  const ClientProfileHeaderCard({
    super.key,
    required this.name,
    required this.goal,
    required this.imageUrl,
    required this.isVerified,
    required this.isUploadingImage,
    required this.onChangePhoto,
  });

  String get _displayName => name.trim().isEmpty ? 'Cliente' : name.trim();

  String get _displayGoal =>
      goal.trim().isEmpty ? 'Objetivo alimenticio no definido' : goal.trim();

  String get _initials {
    return _displayName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 15.h, 16.w, 15.h),
      decoration: BoxDecoration(
        color: RoleTheme.brandBadgeBackground,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: RoleTheme.brandSoft),
        boxShadow: [
          BoxShadow(
            color: RoleTheme.brandPrimary.withValues(alpha: 0.07),
            blurRadius: 16.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              SmoothProfileAvatar(
                imageUrl: imageUrl,
                isLoading: isUploadingImage,
                size: 66.r,
                fallback: _InitialsAvatar(initials: _initials),
                overlayColor: Colors.black.withValues(alpha: 0.14),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: isUploadingImage ? null : onChangePhoto,
                  child: Container(
                    width: 27.w,
                    height: 27.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9.r),
                      border: Border.all(
                        color: RoleTheme.brandPrimary,
                        width: 1.3.w,
                      ),
                    ),
                    child: isUploadingImage
                        ? Padding(
                            padding: EdgeInsets.all(6.w),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: RoleTheme.brandPrimary,
                            ),
                          )
                        : Icon(
                            Icons.camera_alt_rounded,
                            size: 14.sp,
                            color: RoleTheme.iconColorFor(
                              Icons.camera_alt_rounded,
                              fallback: RoleTheme.brandPrimary,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RoleTheme.brandText,
                    fontSize: 17.5.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _displayGoal,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RoleTheme.brandMutedText,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 9.h),
                VerifiedBadge(isVerified: isVerified),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;

  const _InitialsAvatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      child: Text(
        initials.isEmpty ? 'C' : initials,
        style: TextStyle(
          color: RoleTheme.brandPrimary,
          fontSize: 21.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}








