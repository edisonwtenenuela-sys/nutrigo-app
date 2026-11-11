import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';

class CustomerInfoCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onOpenMaps;

  const CustomerInfoCard({
    super.key,
    required this.order,
    required this.onOpenMaps,
  });

  String _initials() {
    final name = order.customerInfo.name.trim();
    if (name.isEmpty) return '?';

    return name.substring(0, 1).toUpperCase();
  }

  bool _hasImage(String? imageUrl) {
    return imageUrl != null && imageUrl.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final imageUrl = order.customerInfo.profileImageUrl;
    final hasImage = _hasImage(imageUrl);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: palette.primary,
                backgroundImage: hasImage ? NetworkImage(imageUrl!.trim()) : null,
                child: hasImage
                    ? null
                    : Text(
                  _initials(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerInfo.name.trim().isEmpty
                          ? 'Cliente'
                          : order.customerInfo.name.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      order.customerInfo.email.trim().isEmpty
                          ? 'Correo no registrado'
                          : order.customerInfo.email.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.mutedText,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: palette.background,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: palette.primary.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: RoleTheme.iconDanger,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    order.shippingAddress.trim().isEmpty
                        ? 'Dirección no registrada'
                        : order.shippingAddress.trim(),
                    style: TextStyle(
                      color: palette.text,
                      fontSize: 11.5.sp,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (order.customerInfo.phoneNumber != null &&
              order.customerInfo.phoneNumber!.trim().isNotEmpty) ...[
            SizedBox(height: 10.h),
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 16.sp,
                  color: RoleTheme.iconValidation,
                ),
                SizedBox(width: 6.w),
                Text(
                  order.customerInfo.phoneNumber!.trim(),
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          if (onOpenMaps != null) ...[
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onOpenMaps,
                icon: Icon(
                  Icons.map_outlined,
                  color: RoleTheme.iconColorFor(
                    Icons.map_outlined,
                    fallback: palette.primary,
                  ),
                  size: 18.sp,
                ),
                label: Text(
                  'Abrir en Google Maps',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.primary.withValues(alpha: 0.055),
                  foregroundColor: palette.primary,
                  side: BorderSide(
                    color: palette.primary.withValues(alpha: 0.22),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 11.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}