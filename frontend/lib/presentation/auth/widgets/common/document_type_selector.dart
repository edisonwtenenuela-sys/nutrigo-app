import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class DocumentTypeSelector extends StatelessWidget {
  final String selectedType;
  final bool isLoading;
  final bool enabled;
  final RolePalette palette;
  final ValueChanged<String> onChanged;

  const DocumentTypeSelector({
    super.key,
    required this.selectedType,
    required this.isLoading,
    this.enabled = true,
    required this.palette,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.11)),
      ),
      child: Row(
        children: [
          _DocumentTypeOption(
            label: 'Cédula',
            helper: '10 dígitos',
            value: 'cédula',
            selectedType: selectedType,
            isLoading: isLoading,
            enabled: enabled,
            palette: palette,
            onChanged: onChanged,
          ),
          SizedBox(width: 6.w),
          _DocumentTypeOption(
            label: 'RUC',
            helper: '13 dígitos',
            value: 'ruc',
            selectedType: selectedType,
            isLoading: isLoading,
            enabled: enabled,
            palette: palette,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _DocumentTypeOption extends StatelessWidget {
  final String label;
  final String helper;
  final String value;
  final String selectedType;
  final bool isLoading;
  final bool enabled;
  final RolePalette palette;
  final ValueChanged<String> onChanged;

  const _DocumentTypeOption({
    required this.label,
    required this.helper,
    required this.value,
    required this.selectedType,
    required this.isLoading,
    required this.enabled,
    required this.palette,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == selectedType;
    final disabled = isLoading || !enabled;

    final backgroundColor = selected ? palette.primary : palette.surface;
    final textColor = selected ? palette.surface : palette.text;
    final helperColor = selected
        ? palette.surface.withValues(alpha: 0.78)
        : palette.mutedText;
    final borderColor = selected
        ? palette.primary
        : palette.primary.withValues(alpha: 0.12);

    return Expanded(
      child: InkWell(
        onTap: disabled ? null : () => onChanged(value),
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: textColor,
                size: 16.sp,
              ),
              SizedBox(width: 7.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 11.8.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      helper,
                      style: TextStyle(
                        color: helperColor,
                        fontSize: 9.7.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}