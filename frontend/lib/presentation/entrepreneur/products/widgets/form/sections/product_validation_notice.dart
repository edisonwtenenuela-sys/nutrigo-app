import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductValidationNotice extends StatelessWidget {
  const ProductValidationNotice({super.key});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: palette.secondary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(color: palette.secondary.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.health_and_safety_rounded,
            color: RoleTheme.iconColorFor(
              Icons.health_and_safety_rounded,
              fallback: palette.secondary,
            ),
            size: 22.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Al enviar a validación, el producto quedará pendiente hasta que un nutricionista revise su información.',
              style: TextStyle(
                color: palette.text,
                fontSize: 12.sp,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}








