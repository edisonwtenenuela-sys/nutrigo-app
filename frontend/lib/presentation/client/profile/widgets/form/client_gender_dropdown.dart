import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/client/controllers/client_profile_controller.dart';

class ClientGenderDropdown extends StatelessWidget {
  final ClientProfileController controller;

  static const List<String> genderOptions = [
    'Femenino',
    'Masculino',
    'Prefiero no decirlo',
  ];

  const ClientGenderDropdown({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    final selectedGender = genderOptions.contains(controller.selectedGender)
        ? controller.selectedGender
        : null;

    return DropdownButtonFormField<String>(
      initialValue: selectedGender,
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        labelText: 'Género',
        labelStyle: TextStyle(
          color: palette.mutedText,
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          Icons.wc_rounded,
          color: palette.primary,
          size: 18.sp,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 12.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: palette.primary.withValues(alpha: 0.12),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: palette.primary.withValues(alpha: 0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: palette.primary,
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.2,
          ),
        ),
      ),
      hint: Text(
        'Selecciona tu género',
        style: TextStyle(
          color: palette.mutedText,
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      items: genderOptions
          .map(
            (gender) => DropdownMenuItem<String>(
          value: gender,
          child: Text(
            gender,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.text,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      )
          .toList(),
      onChanged: controller.isSaving
          ? null
          : (value) {
        controller.updateGender(value);
        controller.clearError();
      },
      validator: (value) =>
          controller.validateRequired(value, 'tu género'),
    );
  }
}