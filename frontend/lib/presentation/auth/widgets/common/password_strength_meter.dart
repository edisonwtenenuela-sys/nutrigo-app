import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/auth/helpers/password_strength_helper.dart';

class PasswordStrengthMeter extends StatelessWidget {
  final String password;
  final RolePalette palette;

  const PasswordStrengthMeter({
    super.key,
    required this.password,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final result = PasswordStrengthEvaluator.evaluate(password);
    final color = _strengthColor(result.level);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: RoleTheme.iconColorFor(
                  Icons.shield_outlined,
                  fallback: color,
                ),
                size: 17.sp,
              ),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(
                  'Seguridad de la contraseña',
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 11.8.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                _strengthLabel(result.level),
                style: TextStyle(
                  color: color,
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: 9.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.r),
            child: LinearProgressIndicator(
              value: _strengthProgress(result.level),
              minHeight: 7.h,
              backgroundColor: palette.primary.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 7.w,
            runSpacing: 7.h,
            children: [
              _RequirementChip(
                text: '8 caracteres',
                passed: result.hasMinLength,
                palette: palette,
              ),
              _RequirementChip(
                text: 'Mayúscula',
                passed: result.hasUppercase,
                palette: palette,
              ),
              _RequirementChip(
                text: 'Minúscula',
                passed: result.hasLowercase,
                palette: palette,
              ),
              _RequirementChip(
                text: 'Número',
                passed: result.hasNumber,
                palette: palette,
              ),
              _RequirementChip(
                text: 'Símbolo',
                passed: result.hasSymbol,
                palette: palette,
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _strengthProgress(PasswordStrengthLevel level) {
    return switch (level) {
      PasswordStrengthLevel.empty => 0,
      PasswordStrengthLevel.weak => 0.34,
      PasswordStrengthLevel.medium => 0.67,
      PasswordStrengthLevel.strong => 1,
    };
  }

  String _strengthLabel(PasswordStrengthLevel level) {
    return switch (level) {
      PasswordStrengthLevel.empty => 'Sin contraseña',
      PasswordStrengthLevel.weak => 'Insegura',
      PasswordStrengthLevel.medium => 'Poco segura',
      PasswordStrengthLevel.strong => 'Segura',
    };
  }

  Color _strengthColor(PasswordStrengthLevel level) {
    return switch (level) {
      PasswordStrengthLevel.empty ||
      PasswordStrengthLevel.weak =>
      RoleTheme.iconDanger,
      PasswordStrengthLevel.medium => RoleTheme.iconWarning,
      PasswordStrengthLevel.strong => RoleTheme.iconValidation,
    };
  }
}

class _RequirementChip extends StatelessWidget {
  final String text;
  final bool passed;
  final RolePalette palette;

  const _RequirementChip({
    required this.text,
    required this.passed,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final color = passed ? RoleTheme.iconValidation : palette.mutedText;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: passed ? 0.10 : 0.07),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            passed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: color,
            size: 13.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10.4.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}