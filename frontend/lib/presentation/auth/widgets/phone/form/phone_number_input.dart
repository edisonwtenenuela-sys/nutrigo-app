import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/auth/helpers/phone_auth_constants.dart';

class PhoneNumberInput extends StatelessWidget {
  final TextEditingController controller;
  final RolePalette palette;
  final bool enabled;

  const PhoneNumberInput({
    super.key,
    required this.controller,
    required this.palette,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(phoneAuthExpectedDigits),
      ],
      enabled: enabled,
      cursorColor: palette.primary,
      style: TextStyle(
        color: palette.text,
        fontSize: 14.sp,
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        labelText: 'Número de teléfono',
        hintText: '$phoneAuthExpectedDigits dígitos',
        labelStyle: TextStyle(
          color: palette.mutedText,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 10.w, right: 7.w),
          child: Container(
            width: 58.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Text(
              phoneAuthCountryCode,
              style: TextStyle(
                color: palette.primary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 78.w),
        suffixIcon: Icon(
          Icons.phone_rounded,
          color: RoleTheme.iconColorFor(
            Icons.phone_rounded,
            fallback: palette.primary,
          ),
          size: 20.sp,
        ),
        filled: true,
        fillColor: palette.primary.withValues(alpha: 0.035),
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: palette.primary.withValues(alpha: 0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: palette.primary,
            width: 1.4.w,
          ),
        ),
      ),
    );
  }
}