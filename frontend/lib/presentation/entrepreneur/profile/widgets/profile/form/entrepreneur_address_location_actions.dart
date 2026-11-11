import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class BusinessAddressLocationActions extends StatelessWidget {
  final bool hasMapLocation;
  final VoidCallback onSelectLocation;

  const BusinessAddressLocationActions({
    super.key,
    required this.hasMapLocation,
    required this.onSelectLocation,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: palette.primary.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit_location_alt_rounded,
                  color: palette.primary,
                  size: 17.sp,
                ),
                SizedBox(width: 7.w),
                Expanded(
                  child: Text(
                    hasMapLocation
                        ? 'Dirección vinculada con ubicación del mapa.'
                        : 'Puedes escribir la dirección manualmente.',
                    style: TextStyle(
                      color: palette.mutedText,
                      fontSize: 10.8.sp,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              height: 42.h,
              child: OutlinedButton.icon(
                onPressed: onSelectLocation,
                icon: Icon(
                  Icons.map_rounded,
                  color: RoleTheme.iconColorFor(Icons.map_rounded),
                  size: 16.sp,
                ),
                label: const Text('Seleccionar en mapa'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.primary,
                  side: BorderSide(
                    color: palette.primary.withValues(alpha: 0.22),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  textStyle: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}








