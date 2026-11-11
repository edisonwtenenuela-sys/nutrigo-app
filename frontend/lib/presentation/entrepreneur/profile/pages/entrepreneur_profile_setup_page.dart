import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';
import 'package:emprendedor/presentation/auth/pages/auth_wrapper.dart';
import 'package:emprendedor/presentation/auth/widgets/index.dart';
import 'package:emprendedor/presentation/entrepreneur/profile/widgets/index.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';
import 'package:emprendedor/presentation/shared/widgets/registration_form_loading_view.dart';

class BusinessProfileSetupPage extends StatefulWidget {
  const BusinessProfileSetupPage({
    super.key,
    required this.userId,
    this.allowBack = false,
  });

  final String userId;
  final bool allowBack;

  @override
  State<BusinessProfileSetupPage> createState() =>
      _BusinessProfileSetupPageState();
}

class _BusinessProfileSetupPageState extends State<BusinessProfileSetupPage> {
  late final BusinessProfileSetupController _formController;
  bool _isPreparingForm = true;

  @override
  void initState() {
    super.initState();
    _formController = BusinessProfileSetupController();
    _finishInitialPreparation();
  }

  Future<void> _finishInitialPreparation() async {
    await _formController.loadExistingProfile(widget.userId);
    await Future<void>.delayed(const Duration(milliseconds: 720));
    if (!mounted) return;
    setState(() => _isPreparingForm = false);
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    showAppMessage(
      context,
      role: AppFeedbackRole.entrepreneur,
      type: isError ? AppFeedbackType.error : AppFeedbackType.success,
      title: isError ? 'No se pudo completar' : 'Listo',
      message: message,
    );
  }

  Future<void> _save() async {
    final result = await _formController.submit(widget.userId);

    if (!mounted) return;
    _showMessage(result.message, isError: !result.success);

    if (!result.success) return;

    AppNavigator.replaceAll(context, const AuthWrapper(), rootNavigator: true);
  }

  Widget _buildRepresentativeSection() {
    const palette = RoleTheme.entrepreneur;

    return BusinessSetupSectionCard(
      title: 'Representante',
      child: Column(
        children: [
          BusinessSetupField(
            controller: _formController.representativeNameController,
            label: 'Nombre del representante',
            icon: Icons.person_rounded,
            enabled: !_formController.isSaving,
            validator: _formController.requiredValidator,
          ),
          DocumentTypeSelector(
            selectedType: _formController.documentType,
            isLoading: _formController.isSaving,
            palette: palette,
            onChanged: _formController.updateDocumentType,
          ),
          SizedBox(height: 9.h),
          BusinessSetupField(
            controller: _formController.documentNumberController,
            label: _formController.documentLabel,
            icon: Icons.badge_rounded,
            enabled: !_formController.isSaving,
            keyboardType: TextInputType.number,
            inputFormatters: _formController.documentFormatters,
            validator: _formController.documentValidator,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessSection() {
    return BusinessSetupSectionCard(
      title: 'Negocio',
      child: Column(
        children: [
          BusinessSetupField(
            controller: _formController.businessNameController,
            label: 'Nombre comercial del negocio',
            icon: Icons.storefront_rounded,
            enabled: !_formController.isSaving,
            validator: _formController.requiredValidator,
          ),
          BusinessSetupField(
            controller: _formController.descriptionController,
            label: 'Descripción breve',
            icon: Icons.description_outlined,
            enabled: !_formController.isSaving,
            maxLines: 2,
            validator: _formController.requiredValidator,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return BusinessSetupSectionCard(
      title: 'Contacto',
      child: Column(
        children: [
          if (_formController.isPhoneRegister)
            BusinessSetupField(
              controller: _formController.emailContactController,
              label: 'Correo electrónico de contacto',
              icon: Icons.email_rounded,
              enabled: !_formController.isSaving,
              keyboardType: TextInputType.emailAddress,
              validator: _formController.emailValidator,
            )
          else
            BusinessSetupField(
              controller: _formController.phoneController,
              label: 'Teléfono o WhatsApp',
              icon: Icons.phone_rounded,
              enabled: !_formController.isSaving,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: _formController.phoneValidator,
            ),
          BusinessSetupField(
            controller: _formController.addressController,
            label: 'Dirección del negocio',
            icon: Icons.location_on_rounded,
            enabled: !_formController.isSaving,
            validator: _formController.requiredValidator,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    if (_isPreparingForm) {
      return const _BusinessProfileSetupLoadingView();
    }

    return ListenableBuilder(
      listenable: _formController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: palette.background,
          appBar: AppBar(
            backgroundColor: palette.background,
            surfaceTintColor: palette.background,
            elevation: 0,
            automaticallyImplyLeading: widget.allowBack,
            centerTitle: true,
            title: Text(
              'Solicitud de aprobación',
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w900,
                color: palette.text,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 18.h),
              child: Form(
                key: _formController.formKey,
                child: Column(
                  children: [
                    const BusinessSetupHeader(),
                    SizedBox(height: 14.h),
                    _buildRepresentativeSection(),
                    SizedBox(height: 10.h),
                    _buildBusinessSection(),
                    SizedBox(height: 10.h),
                    _buildContactSection(),
                    SizedBox(height: 14.h),
                    BusinessSetupSubmitButton(
                      isSaving: _formController.isSaving,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BusinessProfileSetupLoadingView extends StatelessWidget {
  const _BusinessProfileSetupLoadingView();

  @override
  Widget build(BuildContext context) {
    return const RegistrationFormLoadingView(
      palette: RoleTheme.entrepreneur,
      icon: Icons.storefront_rounded,
      eyebrow: 'PERFIL EMPRENDEDOR',
      title: 'Solicitud de negocio',
      message: 'Completa tu información.',
      steps: ['Negocio', 'Contacto', 'Verificacion'],
    );
  }
}








