import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class WelcomeHeader extends StatelessWidget {
  final String greetingText;
  final String? imageUrl;
  final int activeOrders;
  final String monthIncome;

  const WelcomeHeader({
    super.key,
    required this.greetingText,
    this.imageUrl,
    this.activeOrders = 0,
    this.monthIncome = '\$0.00',
  });

  bool get _hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    const palette = RoleTheme.entrepreneur;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isTablet ? 20 : 15.w,
        isTablet ? 16 : 13.h,
        isTablet ? 20 : 15.w,
        isTablet ? 15 : 12.h,
      ),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(isTablet ? 24 : 22.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.07),
            blurRadius: isTablet ? 18 : 14.r,
            offset: Offset(0, isTablet ? 8 : 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: isTablet ? 56 : 48.w,
                height: isTablet ? 56 : 48.w,
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(isTablet ? 18 : 16.r),
                  border: Border.all(
                    color: palette.primary.withValues(alpha: 0.12),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _hasImage
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!.trim(),
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            _loadingIndicator(isTablet: isTablet),
                        errorWidget: (_, _, _) =>
                            _fallbackIcon(isTablet: isTablet),
                      )
                    : _fallbackIcon(isTablet: isTablet),
              ),
              SizedBox(width: isTablet ? 15 : 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greetingText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.text,
                        fontSize: isTablet ? 21 : 16.5.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'Gestiona ventas, productos y pedidos desde un solo panel.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.mutedText,
                        fontSize: isTablet ? 13 : 11.5.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 14 : 11.h),
          Row(
            children: [
              Expanded(
                child: _HeaderMetricPill(
                  icon: Icons.receipt_long_rounded,
                  label: 'Pedidos activos',
                  value: '$activeOrders',
                ),
              ),
              SizedBox(width: isTablet ? 12 : 9.w),
              Expanded(
                child: _HeaderMetricPill(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Ingresos del mes',
                  value: monthIncome,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fallbackIcon({required bool isTablet}) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      alignment: Alignment.center,
      color: Colors.transparent,
      child: Icon(
        Icons.storefront_rounded,
        color: RoleTheme.iconColorFor(
          Icons.storefront_rounded,
          fallback: palette.primary,
        ),
        size: isTablet ? 28 : 23.sp,
      ),
    );
  }

  Widget _loadingIndicator({required bool isTablet}) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      alignment: Alignment.center,
      color: Colors.transparent,
      child: SizedBox(
        width: isTablet ? 23 : 19.r,
        height: isTablet ? 23 : 19.r,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          color: palette.primary,
        ),
      ),
    );
  }
}

class _HeaderMetricPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeaderMetricPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    const palette = RoleTheme.entrepreneur;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 10.w,
        vertical: isTablet ? 11 : 9.5.h,
      ),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 14.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: isTablet ? 30 : 27.w,
            height: isTablet ? 30 : 27.w,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Icon(
              icon,
              color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
              size: isTablet ? 16 : 14.sp,
            ),
          ),
          SizedBox(width: isTablet ? 9 : 7.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.primary,
                    fontSize: isTablet ? 14 : 12.sp,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: isTablet ? 11.5 : 9.6.sp,
                    fontWeight: FontWeight.w800,
                    height: 1,
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
