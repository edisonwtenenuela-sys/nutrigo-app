import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/nutritionist/controllers/nutritionist_profile_controller.dart';
import 'package:emprendedor/presentation/nutritionist/profile/pages/nutritionist_location_picker_page.dart';

class NutritionistMapsButton extends StatelessWidget {
  const NutritionistMapsButton({super.key});

  Future<void> _selectLocation(BuildContext context) async {
    final controller = context.read<NutritionistProfileController>();

    final result = await AppNavigator.push<Map<String, dynamic>>(
      context,
      NutritionistLocationPickerPage(
        initialLatitude: controller.consultationLatitude,
        initialLongitude: controller.consultationLongitude,
      ),
    );

    if (result == null) return;

    final latitude = (result['latitude'] as num?)?.toDouble();
    final longitude = (result['longitude'] as num?)?.toDouble();
    final address = result['address']?.toString();

    if (latitude == null || longitude == null) return;

    controller.setConsultationLocation(
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NutritionistProfileController>();
    const palette = RoleTheme.nutritionist;

    final icon = controller.hasSelectedLocation
        ? Icons.edit_location_alt_rounded
        : Icons.add_location_alt_rounded;

    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: OutlinedButton.icon(
        onPressed: controller.isSaving ? null : () => _selectLocation(context),
        icon: Icon(
          icon,
          color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
          size: 17.sp,
        ),
        label: Text(
          controller.hasSelectedLocation
              ? 'Cambiar ubicación'
              : 'Seleccionar ubicación',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          disabledForegroundColor: palette.mutedText,
          backgroundColor: palette.primary.withValues(alpha: 0.045),
          disabledBackgroundColor: palette.primary.withValues(alpha: 0.025),
          side: BorderSide(
            color: controller.isSaving
                ? palette.mutedText.withValues(alpha: 0.16)
                : palette.primary.withValues(alpha: 0.18),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}