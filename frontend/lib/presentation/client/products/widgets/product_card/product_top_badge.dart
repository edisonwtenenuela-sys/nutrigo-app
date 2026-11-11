import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductTopBadge extends StatelessWidget {
  const ProductTopBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.5.h),
        decoration: BoxDecoration(
          color: RoleTheme.iconRating,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(14.r),
            bottomLeft: Radius.circular(11.r),
          ),
          boxShadow: [
            BoxShadow(
              color: RoleTheme.iconRating.withValues(alpha: 0.22),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, color: Colors.white, size: 10.sp),
            SizedBox(width: 2.5.w),
            Text(
              'TOP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8.5.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductTopMiniBadge extends StatelessWidget {
  const ProductTopMiniBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: RoleTheme.iconRating.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(99.r),
          border: Border.all(
            color: RoleTheme.iconRating.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, color: RoleTheme.iconRating, size: 9.sp),
            SizedBox(width: 2.5.w),
            Text(
              'TOP',
              style: TextStyle(
                color: RoleTheme.iconRating,
                fontSize: 8.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductTopImageBadge extends StatelessWidget {
  const ProductTopImageBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
        decoration: BoxDecoration(
          color: RoleTheme.iconRating,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(14.r),
            bottomLeft: Radius.circular(9.r),
          ),
        ),
        child: Text(
          'TOP',
          style: TextStyle(
            color: Colors.white,
            fontSize: 7.4.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class ProductTopChip extends StatelessWidget {
  const ProductTopChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: RoleTheme.iconRating.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99.r),
        border: Border.all(color: RoleTheme.iconRating.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: RoleTheme.iconRating, size: 12.sp),
          SizedBox(width: 4.w),
          Text(
            'Producto TOP',
            style: TextStyle(
              color: RoleTheme.client.text,
              fontSize: 10.2.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
