import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ClientProfileSelectLocationButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onPressed;

  const ClientProfileSelectLocationButton({
    super.key,
    required this.isSaving,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: isSaving ? null : onPressed,
        icon: Icon(
          Icons.map_rounded,
          size: 16.sp,
          color: RoleTheme.iconColorFor(
            Icons.map_rounded,
            fallback: palette.primary,
          ),
        ),
        label: Text(
          'Seleccionar en el mapa',
          style: TextStyle(
            color: palette.primary,
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}