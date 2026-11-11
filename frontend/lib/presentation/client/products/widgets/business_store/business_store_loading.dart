import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/client/products/widgets/business_store/skeleton_box.dart';
import 'package:emprendedor/presentation/client/products/widgets/business_store/store_product_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BusinessStoreLoading extends StatelessWidget {
  const BusinessStoreLoading({super.key});

  Widget _buildProductsLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Row(
            children: [
              SkeletonBox(width: 172.w, height: 18.h, radius: 8),
              const Spacer(),
              SkeletonBox(width: 28.w, height: 24.h, radius: 99),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        const StoreProductSkeleton(),
        const StoreProductSkeleton(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 18.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: RoleTheme.brandBadgeBackground,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: RoleTheme.brandSoft),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 54.w, height: 54.w, radius: 15),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 130.w, height: 18.h, radius: 8),
                        SizedBox(height: 7.h),
                        SkeletonBox(
                          width: double.infinity,
                          height: 10.h,
                          radius: 7,
                        ),
                        SizedBox(height: 5.h),
                        SkeletonBox(width: 190.w, height: 10.h, radius: 7),
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 6.h,
                          children: [
                            SkeletonBox(width: 105.w, height: 22.h, radius: 8),
                            SkeletonBox(width: 82.w, height: 22.h, radius: 8),
                            SkeletonBox(width: 128.w, height: 22.h, radius: 8),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            _buildProductsLoading(),
          ],
        ),
      ),
    );
  }
}
