import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:emprendedor/core/services/entrepreneur/entrepreneur_profile_setup_service.dart';
import 'package:emprendedor/features/entrepreneur/helpers/index.dart';

class BusinessProfileSetupSubmitResult {
  const BusinessProfileSetupSubmitResult({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;
}

class BusinessProfileSetupController extends ChangeNotifier {
  BusinessProfileSetupController({
    EntrepreneurProfileSetupService? setupService,
  }) : _setupService = setupService ?? EntrepreneurProfileSetupService() {
    final session = _setupService.currentSession();
    representativeNameController.text = session?.displayName ?? '';
    emailContactController.text = session?.email ?? '';
    phoneController.text = BusinessProfileFormHelper.localEcuadorPhone(
      session?.phoneNumber,
    );
  }

  final EntrepreneurProfileSetupService _setupService;
  final formKey = GlobalKey<FormState>();

  final representativeNameController = TextEditingController();
  final businessNameController = TextEditingController();
  final documentNumberController = TextEditingController();
  final descriptionController = TextEditingController();
  final phoneController = TextEditingController();
  final emailContactController = TextEditingController();
  final addressController = TextEditingController();

  String documentType = 'cedula';
  bool isSaving = false;

  bool get isPhoneRegister =>
      _setupService.currentSession()?.isPhoneOnly ?? false;

  List<TextInputFormatter> get documentFormatters =>
      BusinessProfileFormHelper.documentFormatters(documentType);

  Future<void> loadExistingProfile(String userId) async {
    final draft = await _setupService.loadInitialSetupDraft(userId);
    final profile = draft.profile;

    _fillIfPresent(representativeNameController, draft.representativeName);
    _fillIfPresent(emailContactController, draft.email);

    if (profile != null) {
      _fillIfPresent(businessNameController, profile.name);
      _fillIfPresent(descriptionController, profile.description);
      _fillIfPresent(documentNumberController, profile.documentNumber);
      _fillIfPresent(addressController, profile.address);
      _fillIfPresent(
        phoneController,
        BusinessProfileFormHelper.localEcuadorPhone(profile.phone),
      );

      final existingDocumentType = profile.documentType?.trim();
      if (existingDocumentType == 'cedula' || existingDocumentType == 'ruc') {
        documentType = existingDocumentType!;
      }
    }

    notifyListeners();
  }

  void _fillIfPresent(TextEditingController controller, String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return;
    controller.text = text;
  }

  String get documentLabel =>
      documentType == 'ruc' ? 'RUC (13 dígitos)' : 'Cédula (10 dígitos)';

  String? requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Campo obligatorio';
    return null;
  }

  String? phoneValidator(String? value) {
    return BusinessProfileFormHelper.phoneValidator(value);
  }

  String? documentValidator(String? value) {
    return BusinessProfileFormHelper.documentValidator(
      value: value,
      documentType: documentType,
    );
  }

  String? emailValidator(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Campo obligatorio';

    final valid = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
    if (!valid) return 'Ingresa un correo válido';

    return null;
  }

  void updateDocumentType(String value) {
    final maxLength = BusinessProfileFormHelper.documentMaxLength(value);
    documentType = value;
    _trimDocumentIfNeeded(maxLength);
    notifyListeners();
  }

  Future<BusinessProfileSetupSubmitResult> submit(String userId) async {
    if (isSaving) {
      return const BusinessProfileSetupSubmitResult(
        success: false,
        message: 'La solicitud ya se está guardando.',
      );
    }

    if (!(formKey.currentState?.validate() ?? false)) {
      return const BusinessProfileSetupSubmitResult(
        success: false,
        message: 'Completa todos los campos requeridos.',
      );
    }

    final session = _setupService.currentSession();
    if (session == null) {
      return const BusinessProfileSetupSubmitResult(
        success: false,
        message: 'No hay usuario autenticado.',
      );
    }

    _setSaving(true);

    try {
      final resolvedEmail = isPhoneRegister
          ? emailContactController.text.trim()
          : (session.email ?? emailContactController.text.trim());

      final resolvedPhone = isPhoneRegister
          ? BusinessProfileFormHelper.localEcuadorPhone(session.phoneNumber)
          : phoneController.text.trim();

      await _setupService.submitInitialSetup(
        userId: userId,
        representativeName: representativeNameController.text.trim(),
        businessName: businessNameController.text.trim(),
        documentType: documentType,
        documentNumber: documentNumberController.text.trim(),
        description: descriptionController.text.trim(),
        address: addressController.text.trim(),
        phone: resolvedPhone,
        email: resolvedEmail,
      );

      return const BusinessProfileSetupSubmitResult(
        success: true,
        message: 'Solicitud enviada para revisión administrativa.',
      );
    } catch (_) {
      return const BusinessProfileSetupSubmitResult(
        success: false,
        message: 'No se pudo enviar la solicitud de aprobación.',
      );
    } finally {
      _setSaving(false);
    }
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  void _trimDocumentIfNeeded(int maxLength) {
    final digits = _digitsOnly(documentNumberController.text);
    if (digits.length <= maxLength) return;

    documentNumberController.text = digits.substring(0, maxLength);
    documentNumberController.selection = TextSelection.collapsed(
      offset: documentNumberController.text.length,
    );
  }

  void _setSaving(bool value) {
    if (isSaving == value) return;
    isSaving = value;
    notifyListeners();
  }

  @override
  void dispose() {
    representativeNameController.dispose();
    businessNameController.dispose();
    documentNumberController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    emailContactController.dispose();
    addressController.dispose();
    super.dispose();
  }
}








