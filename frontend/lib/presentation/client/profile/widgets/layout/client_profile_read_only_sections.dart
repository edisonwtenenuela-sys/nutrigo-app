import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/client/controllers/client_profile_controller.dart';
import 'package:emprendedor/presentation/client/profile/widgets/layout/client_profile_section_card.dart';

class ClientProfileReadOnlyItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const ClientProfileReadOnlyItem({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final displayValue = value.trim().isEmpty ? 'No especificado' : value.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(11.r),
          ),
          child: Icon(
            icon,
            color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
            size: 17.sp,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: palette.mutedText,
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                displayValue,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 12.7.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ClientProfilePersonalDataSection extends StatelessWidget {
  final ClientProfileController controller;

  const ClientProfilePersonalDataSection({
    super.key,
    required this.controller,
  });

  Widget _gap() => SizedBox(height: 10.h);

  @override
  Widget build(BuildContext context) {
    return ClientProfileSectionCard(
      title: 'Datos personales',
      icon: Icons.badge_rounded,
      children: [
        ClientProfileReadOnlyItem(
          label: 'Nombre completo',
          value: controller.nameController.text,
          icon: Icons.person_rounded,
        ),
        _gap(),
        ClientProfileReadOnlyItem(
          label: 'Teléfono de contacto',
          value: controller.phoneController.text,
          icon: Icons.phone_rounded,
        ),
        _gap(),
        ClientProfileReadOnlyItem(
          label: 'Edad',
          value: controller.ageController.text.isEmpty
              ? ''
              : '${controller.ageController.text} años',
          icon: Icons.cake_rounded,
        ),
        _gap(),
        ClientProfileReadOnlyItem(
          label: 'Género',
          value: controller.selectedGender ?? '',
          icon: Icons.wc_rounded,
        ),
      ],
    );
  }
}

class ClientProfileDeliverySection extends StatelessWidget {
  final ClientProfileController controller;

  const ClientProfileDeliverySection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ClientProfileSectionCard(
      title: 'Entrega y objetivo',
      icon: Icons.flag_rounded,
      children: [
        ClientProfileReadOnlyItem(
          label: 'Dirección',
          value: controller.addressController.text,
          icon: Icons.location_on_rounded,
        ),
        SizedBox(height: 10.h),
        ClientProfileReadOnlyItem(
          label: 'Objetivo alimenticio',
          value: controller.goalController.text,
          icon: Icons.flag_rounded,
        ),
      ],
    );
  }
}

class ClientProfileHealthSection extends StatelessWidget {
  final ClientProfileController controller;

  const ClientProfileHealthSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final allergies = controller.selectedAllergies.isEmpty
        ? 'No especificadas'
        : controller.selectedAllergies.join(', ');

    return ClientProfileSectionCard(
      title: 'Salud y preferencias',
      icon: Icons.favorite_border_rounded,
      children: [
        ClientProfileReadOnlyItem(
          label: 'Peso',
          value: controller.weightController.text.isEmpty
              ? ''
              : '${controller.weightController.text} kg',
          icon: Icons.monitor_weight_outlined,
        ),
        SizedBox(height: 10.h),
        ClientProfileReadOnlyItem(
          label: 'Estatura',
          value: controller.heightController.text.isEmpty
              ? ''
              : '${controller.heightController.text} cm',
          icon: Icons.height_rounded,
        ),
        SizedBox(height: 10.h),
        ClientProfileReadOnlyItem(
          label: 'Alergias',
          value: allergies,
          icon: Icons.health_and_safety_outlined,
        ),
      ],
    );
  }
}