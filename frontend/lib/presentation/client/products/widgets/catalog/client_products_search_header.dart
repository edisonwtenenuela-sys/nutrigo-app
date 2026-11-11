import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ClientProductsSearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final String searchText;
  final int totalProducts;
  final int visibleProducts;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool isLoading;

  const ClientProductsSearchHeader({
    super.key,
    required this.controller,
    required this.searchText,
    required this.totalProducts,
    required this.visibleProducts,
    required this.onChanged,
    required this.onClear,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final hasCatalogContent = isLoading || totalProducts > 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(15.w, 14.h, 15.w, 14.h),
            decoration: BoxDecoration(
              color: hasCatalogContent
                  ? RoleTheme.brandBadgeBackground
                  : palette.surface,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: hasCatalogContent
                    ? RoleTheme.brandSoft.withValues(alpha: 0.72)
                    : RoleTheme.iconHealth.withValues(alpha: 0.10),
              ),
              boxShadow: [
                BoxShadow(
                  color: RoleTheme.iconHealth.withValues(alpha: 0.07),
                  blurRadius: 14.r,
                  offset: Offset(0, 6.h),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: RoleTheme.brandSoft.withValues(alpha: 0.72),
                    ),
                  ),
                  child: Icon(
                    Icons.eco_rounded,
                    color: RoleTheme.iconColorFor(
                      Icons.eco_rounded,
                      fallback: RoleTheme.iconHealth,
                    ),
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 11.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Catálogo validado',
                        style: TextStyle(
                          color: palette.text,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        totalProducts == 0
                            ? 'Productos revisados por nutricionistas'
                            : '$visibleProducts de $totalProducts opciones disponibles',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.mutedText,
                          fontSize: 11.4.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasCatalogContent && totalProducts > 0) ...[
                  SizedBox(width: 8.w),
                  _HeaderCountBadge(
                    value: '$visibleProducts',
                    label: 'Opciones',
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 44.h,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(
                color: palette.text,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar comida, ingrediente o categoría',
                hintStyle: TextStyle(
                  color: palette.mutedText,
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: RoleTheme.iconHealth,
                  size: 21.sp,
                ),
                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: RoleTheme.iconColorFor(
                            Icons.close_rounded,
                            fallback: palette.mutedText,
                          ),
                          size: 19.sp,
                        ),
                        onPressed: onClear,
                      )
                    : null,
                filled: true,
                fillColor: palette.surface,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.r),
                  borderSide: BorderSide(
                    color: RoleTheme.iconHealth.withValues(alpha: 0.08),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.r),
                  borderSide: BorderSide(
                    color: RoleTheme.iconHealth.withValues(alpha: 0.08),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.r),
                  borderSide: const BorderSide(
                    color: RoleTheme.iconHealth,
                    width: 1.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCountBadge extends StatelessWidget {
  final String value;
  final String label;

  const _HeaderCountBadge({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62.w,
      padding: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: RoleTheme.brandSoft.withValues(alpha: 0.72)),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: RoleTheme.iconHealth,
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              color: RoleTheme.brandMutedText,
              fontSize: 8.7.sp,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
