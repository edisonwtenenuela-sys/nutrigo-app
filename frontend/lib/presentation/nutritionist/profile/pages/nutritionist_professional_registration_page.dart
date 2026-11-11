import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/core/utils/professional_registry_utils.dart';
import 'package:emprendedor/features/nutritionist/controllers/nutritionist_professional_registration_controller.dart';
import 'package:emprendedor/presentation/auth/pages/auth_wrapper.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';
import 'package:emprendedor/presentation/shared/widgets/registration_form_loading_view.dart';

class NutritionistProfessionalRegistrationPage extends StatefulWidget {
  const NutritionistProfessionalRegistrationPage({
    super.key,
    this.allowBack = false,
  });

  final bool allowBack;

  @override
  State<NutritionistProfessionalRegistrationPage> createState() =>
      _NutritionistProfessionalRegistrationPageState();
}

class _NutritionistProfessionalRegistrationPageState
    extends State<NutritionistProfessionalRegistrationPage> {
  late final NutritionistProfessionalRegistrationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = NutritionistProfessionalRegistrationController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.loadExistingProfile();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      final result = await _controller.submit();

      if (!mounted || result == null) return;

      _showMessage(result.message);

      await AppNavigator.replaceAll(
        context,
        const AuthWrapper(),
        rootNavigator: true,
      );
    } on NutritionistProfessionalRegistrationFailure catch (e) {
      if (!mounted) return;

      _showMessage(e.message, isError: true);
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'No se pudo guardar el registro profesional.',
        isError: true,
      );
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    showAppMessage(
      context,
      role: AppFeedbackRole.nutritionist,
      type: isError ? AppFeedbackType.error : AppFeedbackType.success,
      title: isError ? 'No se pudo completar' : 'Listo',
      message: message,
    );
  }

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

  Widget _headerCard(String email) {
    const palette = RoleTheme.nutritionist;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        gradient: palette.headerGradient,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Icon(
              Icons.verified_user_rounded,
              color: RoleTheme.iconColorFor(
                Icons.verified_user_rounded,
                fallback: palette.surface,
              ),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Completa tu perfil profesional',
                  style: TextStyle(
                    color: palette.surface,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  email.isEmpty
                      ? 'Estos datos serán revisados por el administrador.'
                      : '$email\nCorreo vinculado a tu cuenta.',
                  style: TextStyle(
                    color: palette.surface.withValues(alpha: 0.88),
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hintText,
    int maxLines = 1,
  }) {
    const palette = RoleTheme.nutritionist;
    final radius = BorderRadius.circular(16.r);

    return InputDecoration(
      labelText: label,
      hintText: hintText,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: TextStyle(
        color: palette.mutedText,
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w700,
      ),
      hintStyle: TextStyle(
        color: palette.mutedText.withValues(alpha: 0.75),
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(
        icon,
        color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
        size: 20.sp,
      ),
      filled: true,
      fillColor: palette.surface.withValues(alpha: 0.92),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: maxLines > 1 ? 16.h : 13.h,
      ),
      border: OutlineInputBorder(borderRadius: radius),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: palette.primary.withValues(alpha: 0.18)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: palette.primary.withValues(alpha: 0.55),
          width: 1.4.w,
        ),
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
          width: 1.4.w,
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? hintText,
    int maxLines = 1,
  }) {
    const palette = RoleTheme.nutritionist;

    return TextFormField(
      controller: controller,
      validator: validator ?? _controller.requiredField,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      enabled: !_controller.isSaving,
      cursorColor: palette.primary,
      style: TextStyle(
        color: palette.text,
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
      ),
      decoration: _inputDecoration(
        label: label,
        icon: icon,
        hintText: hintText,
        maxLines: maxLines,
      ),
    );
  }

  Widget _selectField({
    required String label,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    const palette = RoleTheme.nutritionist;

    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: _inputDecoration(label: label, icon: icon),
      dropdownColor: palette.surface,
      style: TextStyle(
        color: palette.text,
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
      ),
      validator: validator,
      items: items,
      onChanged: _controller.isSaving ? null : onChanged,
    );
  }

  Widget _buildSubmitButton() {
    const palette = RoleTheme.nutritionist;

    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton.icon(
        onPressed: _controller.isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.surface,
          disabledBackgroundColor: palette.primary.withValues(alpha: 0.35),
          disabledForegroundColor: palette.surface.withValues(alpha: 0.72),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        icon: _controller.isSaving
            ? SizedBox(
          width: 18.w,
          height: 18.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: palette.surface,
          ),
        )
            : Icon(
          Icons.send_rounded,
          color: RoleTheme.iconColorFor(
            Icons.send_rounded,
            fallback: palette.surface,
          ),
        ),
        label: Text(
          _controller.isSaving
              ? 'Enviando...'
              : 'Enviar solicitud de verificación',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final email = _controller.currentEmail;

        if (_controller.isLoadingExistingProfile) {
          return const _NutritionistRegistrationLoadingView();
        }

        final isCustomSpecialty = _controller.isCustomSpecialty;

        return Scaffold(
          backgroundColor: palette.background,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: palette.background,
            surfaceTintColor: palette.background,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: widget.allowBack,
            elevation: 0,
            iconTheme: IconThemeData(color: palette.text),
            title: Text(
              'Registro profesional',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: palette.text,
                letterSpacing: -0.3,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(18.w),
              child: Form(
                key: _controller.formKey,
                child: Column(
                  children: [
                    _headerCard(email),
                    SizedBox(height: 10.h),
                    _helperText(
                      'Tu solicitud quedará pendiente de aprobación administrativa.',
                    ),
                    SizedBox(height: 22.h),
                    _field(
                      controller: _controller.nameController,
                      label: 'Nombre completo',
                      icon: Icons.person_rounded,
                    ),
                    SizedBox(height: 12.h),
                    _field(
                      controller: _controller.phoneController,
                      label: 'Teléfono o WhatsApp',
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      hintText: 'Ej: 0999999999',
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: _controller.validatePhone,
                    ),
                    _helperText('Número para contacto con clientes y citas.'),
                    SizedBox(height: 12.h),
                    _selectField(
                      label: 'Especialidad',
                      icon: Icons.medical_services_rounded,
                      value: _controller.selectedSpecialty,
                      items: ProfessionalRegistryUtils.specialtyOptions
                          .map(
                            (specialty) => DropdownMenuItem(
                          value: specialty,
                          child: Text(specialty),
                        ),
                      )
                          .toList(),
                      validator: _controller.validateSpecialty,
                      onChanged: _controller.updateSpecialty,
                    ),
                    _helperText(
                      'Selecciona una especialidad para facilitar filtros y citas.',
                    ),
                    if (isCustomSpecialty) ...[
                      SizedBox(height: 12.h),
                      _field(
                        controller: _controller.specialtyController,
                        label: 'Otra especialidad',
                        icon: Icons.edit_rounded,
                        hintText: 'Ej: Nutrición oncológica',
                      ),
                    ],
                    SizedBox(height: 12.h),
                    _selectField(
                      label: 'Tipo de registro profesional',
                      icon: Icons.fact_check_rounded,
                      value: _controller.registryType,
                      items: ProfessionalRegistryUtils.registryTypes
                          .map(
                            (type) => DropdownMenuItem(
                          value: type,
                          child: Text(
                            ProfessionalRegistryUtils.registryTypeLabel(
                              type,
                            ),
                          ),
                        ),
                      )
                          .toList(),
                      validator: ProfessionalRegistryUtils.validateRegistryType,
                      onChanged: _controller.updateRegistryType,
                    ),
                    _helperText(
                      'Selecciona el sistema donde consta tu registro profesional.',
                    ),
                    SizedBox(height: 12.h),
                    _field(
                      controller: _controller.licenseController,
                      label: ProfessionalRegistryUtils.registryFieldLabel(
                        _controller.registryType,
                      ),
                      icon: Icons.workspace_premium_rounded,
                      hintText: ProfessionalRegistryUtils.registryHint(
                        _controller.registryType,
                      ),
                      keyboardType:
                      _controller.registryType ==
                          ProfessionalRegistryUtils.acess
                          ? TextInputType.text
                          : TextInputType.number,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters:
                      ProfessionalRegistryUtils.licenseInputFormatters(
                        _controller.registryType,
                      ),
                      validator: _controller.validateLicense,
                    ),
                    SizedBox(height: 12.h),
                    _field(
                      controller: _controller.descriptionController,
                      label: 'Descripción profesional',
                      icon: Icons.description_rounded,
                      hintText: 'Experiencia, enfoque nutricional o servicios.',
                      maxLines: 3,
                      validator: _controller.validateDescription,
                    ),
                    SizedBox(height: 22.h),
                    _buildSubmitButton(),
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

class _NutritionistRegistrationLoadingView extends StatelessWidget {
  const _NutritionistRegistrationLoadingView();

  @override
  Widget build(BuildContext context) {
    return const RegistrationFormLoadingView(
      palette: RoleTheme.nutritionist,
      icon: Icons.workspace_premium_rounded,
      eyebrow: 'PERFIL NUTRICIONISTA',
      title: 'Registro profesional',
      message: 'Completa tus datos.',
      steps: ['Identidad', 'Credencial', 'Consulta'],
    );
  }
}
