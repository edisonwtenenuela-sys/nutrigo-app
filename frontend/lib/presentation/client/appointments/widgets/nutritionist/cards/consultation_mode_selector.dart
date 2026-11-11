import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';

class ConsultationModeSelector extends StatelessWidget {
  final List<NutritionistConsultationMode> modes;
  final NutritionistConsultationMode? selectedMode;
  final ValueChanged<NutritionistConsultationMode>? onChanged;

  const ConsultationModeSelector({
    super.key,
    required this.modes,
    required this.selectedMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: modes.map((mode) {
        final isSelected = selectedMode == mode;

        final icon = mode == NutritionistConsultationMode.virtual
            ? Icons.video_call_rounded
            : Icons.location_on_rounded;

        final accentColor =
        mode == NutritionistConsultationMode.virtual
            ? RoleTheme.iconCommunication
            : RoleTheme.iconLocation;

        return ChoiceChip(
          selected: isSelected,
          showCheckmark: false,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15.sp,
                color: isSelected ? Colors.white : accentColor,
              ),
              SizedBox(width: 5.w),
              Text(
                mode.label,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.white : accentColor,
                ),
              ),
            ],
          ),
          selectedColor: accentColor,
          backgroundColor: accentColor.withValues(alpha: 0.08),
          side: BorderSide(
            color: accentColor.withValues(alpha: 0.18),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.r),
          ),
          onSelected: (_) => onChanged?.call(mode),
        );
      }).toList(),
    );
  }
}