import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/auth/widgets/index.dart';

class PhoneRegistrationFields extends StatelessWidget {
  final String selectedRole;
  final String documentType;
  final int documentDigitLimit;
  final bool isLoading;
  final RolePalette palette;
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController ageController;
  final TextEditingController dietaryGoalController;
  final TextEditingController documentNumberController;
  final TextEditingController businessDescriptionController;
  final TextEditingController specialtyController;
  final TextEditingController licenseNumberController;
  final TextEditingController professionalDescriptionController;
  final TextEditingController nutritionistEmailController;
  final TextEditingController contactEmailController;
  final ValueChanged<String> onDocumentTypeChanged;

  const PhoneRegistrationFields({
    super.key,
    required this.selectedRole,
    required this.documentType,
    required this.documentDigitLimit,
    required this.isLoading,
    required this.palette,
    required this.nameController,
    required this.addressController,
    required this.ageController,
    required this.dietaryGoalController,
    required this.documentNumberController,
    required this.businessDescriptionController,
    required this.specialtyController,
    required this.licenseNumberController,
    required this.professionalDescriptionController,
    required this.nutritionistEmailController,
    required this.contactEmailController,
    required this.onDocumentTypeChanged,
  });

  bool get _isClient => selectedRole == 'cliente';
  bool get _isEntrepreneur => selectedRole == 'emprendedor';
  bool get _isNutritionist => selectedRole == 'nutricionista';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PhoneAuthFormField(
          controller: nameController,
          label: _isEntrepreneur ? 'Nombre del negocio' : 'Nombre completo',
          icon: _isEntrepreneur
              ? Icons.storefront_rounded
              : Icons.person_rounded,
          palette: palette,
          enabled: !isLoading,
        ),
        SizedBox(height: 12.h),
        if (_isClient) ..._clientFields,
        if (_isEntrepreneur) ..._entrepreneurFields,
        if (_isNutritionist) ..._nutritionistFields,
      ],
    );
  }

  List<Widget> get _clientFields {
    return [
      PhoneAuthFormField(
        controller: contactEmailController,
        label: 'Correo electrónico',
        icon: Icons.email_rounded,
        keyboardType: TextInputType.emailAddress,
        palette: palette,
        enabled: !isLoading,
      ),
      SizedBox(height: 12.h),
      PhoneAuthFormField(
        controller: ageController,
        label: 'Edad',
        icon: Icons.cake_rounded,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
        palette: palette,
        enabled: !isLoading,
      ),
      SizedBox(height: 12.h),
      PhoneAuthFormField(
        controller: addressController,
        label: 'Dirección',
        icon: Icons.location_on_rounded,
        palette: palette,
        enabled: !isLoading,
      ),
      SizedBox(height: 12.h),
      PhoneAuthFormField(
        controller: dietaryGoalController,
        label: 'Objetivo alimenticio',
        icon: Icons.flag_rounded,
        palette: palette,
        enabled: !isLoading,
      ),
      SizedBox(height: 12.h),
    ];
  }

  List<Widget> get _entrepreneurFields {
    return [
      PhoneAuthFormField(
        controller: contactEmailController,
        label: 'Correo electrónico',
        icon: Icons.email_rounded,
        keyboardType: TextInputType.emailAddress,
        palette: palette,
        enabled: !isLoading,
      ),
      SizedBox(height: 12.h),
      DocumentTypeSelector(
        selectedType: documentType,
        isLoading: isLoading,
        palette: palette,
        onChanged: onDocumentTypeChanged,
      ),
      SizedBox(height: 12.h),
      PhoneAuthFormField(
        controller: documentNumberController,
        label: documentType == 'ruc'
            ? 'RUC (13 dígitos)'
            : 'Cédula (10 dígitos)',
        icon: Icons.badge_rounded,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(documentDigitLimit),
        ],
        palette: palette,
        enabled: !isLoading,
      ),
      SizedBox(height: 12.h),
      PhoneAuthFormField(
        controller: addressController,
        label: 'Dirección del negocio',
        icon: Icons.location_on_rounded,
        palette: palette,
        enabled: !isLoading,
      ),
      SizedBox(height: 12.h),
      PhoneAuthFormField(
        controller: businessDescriptionController,
        label: 'Descripción del negocio',
        icon: Icons.description_rounded,
        maxLines: 2,
        palette: palette,
        enabled: !isLoading,
      ),
      SizedBox(height: 12.h),
    ];
  }

  List<Widget> get _nutritionistFields {
    return [
      PhoneAuthFormField(
        controller: nutritionistEmailController,
        label: 'Correo electrónico',
        icon: Icons.email_rounded,
        keyboardType: TextInputType.emailAddress,
        palette: palette,
        enabled: !isLoading,
      ),
      SizedBox(height: 12.h),
      PhoneAuthFormField(
        controller: specialtyController,
        label: 'Especialidad',
        icon: Icons.medical_services_rounded,
        palette: palette,
        enabled: !isLoading,
      ),
      SizedBox(height: 12.h),
      PhoneAuthFormField(
        controller: licenseNumberController,
        label: 'Registro profesional',
        icon: Icons.workspace_premium_rounded,
        textCapitalization: TextCapitalization.characters,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
          LengthLimitingTextInputFormatter(30),
        ],
        palette: palette,
        enabled: !isLoading,
      ),
      SizedBox(height: 12.h),
      PhoneAuthFormField(
        controller: professionalDescriptionController,
        label: 'Descripción profesional',
        icon: Icons.description_rounded,
        maxLines: 2,
        palette: palette,
        enabled: !isLoading,
      ),
      SizedBox(height: 12.h),
    ];
  }
}