import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/client/products/widgets/business_store/skeleton_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StoreProductSkeleton extends StatelessWidget {
  const StoreProductSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: RoleTheme.client.surface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: RoleTheme.iconHealth.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            SkeletonBox(width: 82.w, height: 82.w, radius: 16),
            SizedBox(width: 11.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 150.w, height: 15.h, radius: 8),
                  SizedBox(height: 7.h),
                  SkeletonBox(width: double.infinity, height: 10.h, radius: 8),
                  SizedBox(height: 5.h),
                  SkeletonBox(width: 190.w, height: 10.h, radius: 8),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      SkeletonBox(width: 72.w, height: 20.h, radius: 99),
                      SizedBox(width: 6.w),
                      SkeletonBox(width: 64.w, height: 20.h, radius: 99),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
