import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/core/utils/professional_registry_utils.dart';
import 'package:emprendedor/features/nutritionist/controllers/nutritionist_profile_controller.dart';
import 'package:emprendedor/presentation/nutritionist/profile/widgets/form/nutritionist_profile_input.dart';
import 'package:emprendedor/presentation/nutritionist/profile/widgets/layout/nutritionist_profile_section_title.dart';

class NutritionistProfessionalSection extends StatelessWidget {
  const NutritionistProfessionalSection({super.key});

  Widget _helperText(String text) {
    const palette = RoleTheme.nutritionist;

    return Padding(
      padding: EdgeInsets.only(top: 6.h, left: 4.w),
      child: Text(
        text,
        style: TextStyle(
          color: palette.mutedText,
          fontSize: 10.8.sp,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
      ),
    );
  }

  InputDecoration _selectDecoration({
    required String label,
    required IconData icon,
    bool enabled = true,
  }) {
    const palette = RoleTheme.nutritionist;
    final radius = BorderRadius.circular(18.r);

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: palette.mutedText,
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w700,
      ),
      prefixIcon: Icon(
        icon,
        color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
        size: 20.sp,
      ),
      filled: true,
      fillColor: enabled
          ? palette.background
          : palette.background.withValues(alpha: 0.55),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      border: OutlineInputBorder(borderRadius: radius),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: palette.primary.withValues(alpha: 0.10)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: palette.primary.withValues(alpha: 0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: palette.primary, width: 1.3.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: RoleTheme.iconDanger.withValues(alpha: 0.55),
          width: 1.2.w,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: RoleTheme.iconDanger.withValues(alpha: 0.75),
          width: 1.3.w,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NutritionistProfileController>();
    const palette = RoleTheme.nutritionist;

    final specialtyText = controller.specialtyController.text.trim();
    final specialtyValue =
        ProfessionalRegistryUtils.specialtyOptions.contains(specialtyText)
        ? specialtyText
        : specialtyText.isEmpty
        ? null
        : 'Otra';
    final isCustomSpecialty = specialtyValue == 'Otra';
    final isRegistryLocked = controller.isProfessionalRegistryLocked;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NutritionistProfileSectionTitle(
          icon: Icons.person_outline_rounded,
          title: 'Datos profesionales',
          subtitle:
              'Completa esta información para que el administrador pueda revisar tu perfil.',
        ),
        SizedBox(height: 14.h),
        NutritionistProfileInput(
          controller: controller.nameController,
          label: 'Nombre completo',
          icon: Icons.badge_outlined,
          hintText: 'Ej: María López',
          validator: (value) => controller.validateRequired(value, 'tu nombre'),
          onChanged: controller.clearError,
        ),
        SizedBox(height: 12.h),
        NutritionistProfileInput(
          controller: controller.phoneController,
          label: 'Teléfono / WhatsApp',
          icon: Icons.phone_outlined,
          hintText: 'Ej: 0999999999',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: controller.validatePhone,
          onChanged: controller.clearError,
        ),
        SizedBox(height: 12.h),
        DropdownButtonFormField<String>(
          initialValue: specialtyValue,
          decoration: _selectDecoration(
            label: 'Especialidad',
            icon: Icons.workspace_premium_outlined,
            enabled: !isRegistryLocked,
          ),
          dropdownColor: palette.surface,
          style: TextStyle(
            color: isRegistryLocked ? palette.mutedText : palette.text,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
          items: ProfessionalRegistryUtils.specialtyOptions
              .map(
                (specialty) => DropdownMenuItem<String>(
                  value: specialty,
                  child: Text(specialty),
                ),
              )
              .toList(),
          validator: (value) =>
              controller.validateRequired(value, 'tu especialidad'),
          onChanged: controller.isSaving || isRegistryLocked
              ? null
              : (value) {
                  if (value == null) return;
                  controller.setSpecialty(value);
                  controller.clearError();
                },
        ),
        _helperText(
          isRegistryLocked
              ? 'La especialidad queda protegida mientras tu perfil está en validación o ya fue aprobado.'
              : 'Selecciona una especialidad para facilitar filtros y citas.',
        ),
        if (isCustomSpecialty) ...[
          SizedBox(height: 12.h),
          NutritionistProfileInput(
            controller: controller.specialtyController,
            label: 'Otra especialidad',
            icon: Icons.edit_rounded,
            hintText: 'Ej: Nutrición oncológica',
            validator: (value) =>
                controller.validateRequired(value, 'tu especialidad'),
            onChanged: controller.clearError,
            enabled: !isRegistryLocked,
          ),
        ],
        SizedBox(height: 12.h),
        DropdownButtonFormField<String>(
          initialValue: controller.professionalRegistryType,
          decoration: _selectDecoration(
            label: 'Tipo de registro profesional',
            icon: Icons.fact_check_outlined,
            enabled: !isRegistryLocked,
          ),
          dropdownColor: palette.surface,
          style: TextStyle(
            color: isRegistryLocked ? palette.mutedText : palette.text,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
          items: ProfessionalRegistryUtils.registryTypes
              .map(
                (type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    ProfessionalRegistryUtils.registryTypeLabel(type),
                  ),
                ),
              )
              .toList(),
          validator: ProfessionalRegistryUtils.validateRegistryType,
          onChanged: controller.isSaving || isRegistryLocked
              ? null
              : (value) {
                  if (value == null) return;
                  controller.setProfessionalRegistryType(value);
                  controller.clearError();
                },
        ),
        _helperText(
          isRegistryLocked
              ? 'Registro bloqueado porque tu perfil ya fue enviado a validación. Si necesitas cambiarlo, solicita revisión al administrador.'
              : 'Selecciona el sistema donde consta tu registro profesional.',
        ),
        SizedBox(height: 12.h),
        NutritionistProfileInput(
          controller: controller.licenseNumberController,
          label: ProfessionalRegistryUtils.registryFieldLabel(
            controller.professionalRegistryType,
          ),
          icon: Icons.verified_user_outlined,
          hintText: ProfessionalRegistryUtils.registryHint(
            controller.professionalRegistryType,
          ),
          keyboardType:
              controller.professionalRegistryType ==
                  ProfessionalRegistryUtils.acess
              ? TextInputType.text
              : TextInputType.number,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: ProfessionalRegistryUtils.licenseInputFormatters(
            controller.professionalRegistryType,
          ),
          validator: controller.validateLicenseNumber,
          onChanged: controller.clearError,
          enabled: !isRegistryLocked,
        ),
        SizedBox(height: 12.h),
        NutritionistProfileInput(
          controller: controller.descriptionController,
          label: 'Descripción profesional',
          icon: Icons.description_outlined,
          hintText:
              'Describe tu experiencia, enfoque nutricional y servicios principales.',
          maxLines: 5,
          validator: (value) =>
              controller.validateRequired(value, 'una descripción'),
          onChanged: controller.clearError,
        ),
      ],
    );
  }
}
