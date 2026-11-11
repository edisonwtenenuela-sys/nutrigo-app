import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/client/controllers/client_profile_controller.dart';

class ClientGoalDropdown extends StatelessWidget {
  final List<String> goals;
  final ClientProfileController controller;

  const ClientGoalDropdown({
    super.key,
    required this.goals,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final currentGoal = controller.goalController.text.trim();
    final selectedGoal = goals.contains(currentGoal) ? currentGoal : null;

    return DropdownButtonFormField<String>(
      initialValue: selectedGoal,
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        labelText: 'Objetivo alimenticio',
        labelStyle: TextStyle(
          color: palette.mutedText,
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          Icons.flag_rounded,
          color: RoleTheme.iconColorFor(
            Icons.flag_rounded,
            fallback: palette.primary,
          ),
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
        'Selecciona tu objetivo',
        style: TextStyle(
          color: palette.mutedText,
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      items: goals
          .map(
            (goal) => DropdownMenuItem<String>(
          value: goal,
          child: Text(
            goal,
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
        if (value == null) return;
        controller.goalController.text = value;
        controller.clearError();
      },
      validator: (value) => controller.validateRequired(value, 'tu objetivo'),
    );
  }
}