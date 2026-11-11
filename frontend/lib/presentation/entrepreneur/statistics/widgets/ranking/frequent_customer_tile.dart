import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/stats/stats_model.dart';

class FrequentCustomerTile extends StatelessWidget {
  final FrequentCustomerStat customer;

  const FrequentCustomerTile({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final customerName = customer.customerName.trim().isNotEmpty
        ? customer.customerName.trim()
        : 'Cliente';

    final imageUrl = customer.profileImageUrl?.trim();

    final totalSpent = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
      locale: 'es_ES',
    ).format(customer.totalSpent);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          _CustomerAvatar(imageUrl: imageUrl),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: palette.accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Text(
                    '${customer.totalOrders} pedidos',
                    style: TextStyle(
                      color: palette.accent,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Gastado',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  totalSpent,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.primary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
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

class _CustomerAvatar extends StatelessWidget {
  const _CustomerAvatar({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl?.trim();

    return Container(
      width: 52.r,
      height: 52.r,
      padding: EdgeInsets.all(1.5.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: cleanUrl == null || cleanUrl.isEmpty
            ? _avatarFallback()
            : CachedNetworkImage(
                imageUrl: cleanUrl,
                fit: BoxFit.cover,
                width: 52.r,
                height: 52.r,
                fadeInDuration: Duration.zero,
                fadeOutDuration: Duration.zero,
                placeholder: (context, url) => _avatarFallback(),
                errorWidget: (context, url, error) => _avatarFallback(),
              ),
      ),
    );
  }

  Widget _avatarFallback() {
    const palette = RoleTheme.entrepreneur;

    return Container(
      color: palette.primary.withValues(alpha: 0.10),
      child: Icon(
        Icons.person_rounded,
        color: RoleTheme.iconColorFor(
          Icons.person_rounded,
          fallback: palette.primary,
        ),
        size: 24.sp,
      ),
    );
  }
}
