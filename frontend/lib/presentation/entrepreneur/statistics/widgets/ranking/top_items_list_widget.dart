import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

enum TopListType { products, customers }

class TopItemsListWidget<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<T> items;
  final TopListType type;
  final Widget Function(BuildContext context, T item) itemBuilder;

  const TopItemsListWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.items,
    required this.type,
    required this.itemBuilder,
  });

  String get _emptyMessage {
    switch (type) {
      case TopListType.products:
        return 'Aún no hay productos destacados.';
      case TopListType.customers:
        return 'Aún no hay clientes frecuentes.';
    }
  }

  IconData get _icon {
    switch (type) {
      case TopListType.products:
        return Icons.restaurant_menu_rounded;
      case TopListType.customers:
        return Icons.people_alt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.04),
            blurRadius: 16.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: items.isEmpty ? _buildEmptyContent() : _buildListContent(),
    );
  }

  Widget _buildHeader() {
    const palette = RoleTheme.entrepreneur;
    final hasSubtitle = subtitle?.trim().isNotEmpty ?? false;

    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(13.r),
          ),
          child: Icon(
            _icon,
            color: RoleTheme.iconColorFor(
              _icon,
              fallback: palette.primary,
            ),
            size: 21.sp,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 14.2.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (hasSubtitle) ...[
                SizedBox(height: 2.h),
                Text(
                  subtitle!.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 10.8.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyContent() {
    const palette = RoleTheme.entrepreneur;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 13.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(13.w),
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: palette.primary.withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            _emptyMessage,
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 14.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return itemBuilder(context, items[index]);
          },
          separatorBuilder: (context, index) {
            return SizedBox(height: 10.h);
          },
        ),
      ],
    );
  }
}