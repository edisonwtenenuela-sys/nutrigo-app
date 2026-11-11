import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class ProductFeaturedSwitch extends StatelessWidget {
  final bool enabled;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ProductFeaturedSwitch({
    super.key,
    required this.enabled,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32.w,
      height: 24.h,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeThumbColor: RoleTheme.brandPrimary,
          activeTrackColor: RoleTheme.brandPrimary.withValues(alpha: 0.32),
        ),
      ),
    );
  }
}
