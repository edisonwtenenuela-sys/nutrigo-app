import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/features/auth/controllers/auth_session_controller.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/entrepreneur/controllers/business_profile_edit_controller.dart';
import 'package:emprendedor/features/entrepreneur/controllers/profile_controller.dart';
import 'package:emprendedor/presentation/auth/pages/auth_landing_page.dart';
import 'package:emprendedor/presentation/auth/widgets/index.dart';
import 'package:emprendedor/features/client/controllers/client_location_picker_controller.dart';
import 'package:emprendedor/presentation/client/cart/pages/select_location_page.dart';
import 'package:emprendedor/features/entrepreneur/helpers/index.dart';
import 'package:emprendedor/presentation/entrepreneur/profile/widgets/index.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';
import 'package:emprendedor/presentation/shared/widgets/common/logout_dialog.dart';
import 'package:emprendedor/presentation/shared/widgets/profile_email_verification_card.dart';

class BusinessProfileEditPage extends StatefulWidget {
  final String userId;

  const BusinessProfileEditPage({super.key, required this.userId});

  @override
  State<BusinessProfileEditPage> createState() =>
      _BusinessProfileEditPageState();
}

class _BusinessProfileEditPageState extends State<BusinessProfileEditPage> {
  final AuthSessionController _sessionController = AuthSessionController();
  late final BusinessProfileEditController _editController;

  List<TextInputFormatter> get _documentFormatters =>
      BusinessProfileFormHelper.documentFormatters(
        _editController.documentType,
      );

  @override
  void initState() {
    super.initState();
    _editController = BusinessProfileEditController(userId: widget.userId);

    final profile = context.read<ProfileController>().businessProfile;
    if (profile != null) _editController.populateFormFromProfile(profile);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _editController.loadUserEmail(context.read<ProfileController>());
    });
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirm = await showLogoutDialog(
      context,
      role: AppFeedbackRole.entrepreneur,
    );

    if (!confirm || !mounted) return;

    final logoutFuture = _sessionController.logout(context);
    AppNavigator.replaceAll(context, const AuthLandingPage());

    await logoutFuture;
  }

  void _showCustomNotification(BusinessProfileEditFeedback feedback) {
    if (!mounted) return;

    showAppMessage(
      context,
      role: AppFeedbackRole.entrepreneur,
      type: switch (feedback.type) {
        BusinessProfileEditFeedbackType.success => AppFeedbackType.success,
        BusinessProfileEditFeedbackType.error => AppFeedbackType.error,
        BusinessProfileEditFeedbackType.warning => AppFeedbackType.warning,
        BusinessProfileEditFeedbackType.info => AppFeedbackType.info,
      },
      title: feedback.title,
      message: feedback.message,
    );
  }

  Future<void> _pickImage() async {
    final feedback = await _editController.pickImage(
      context.read<ProfileController>(),
    );

    if (!mounted || feedback == null) return;
    _showCustomNotification(feedback);
  }

  Future<void> _selectLocation() async {
    final result = await AppNavigator.push<SelectedLocationResult>(
      context,
      SelectLocationPage(
        initialAddress: _editController.addressController.text,
        initialLatitude: _editController.selectedLatitude,
        initialLongitude: _editController.selectedLongitude,
        useCurrentLocationAsInitial: false,
      ),
    );

    if (!mounted || result == null) return;
    _editController.setLocation(result);
  }

  Future<void> _saveProfile() async {
    final feedback = await _editController.saveProfile(
      context.read<ProfileController>(),
    );

    if (!mounted) return;
    if (feedback.type == BusinessProfileEditFeedbackType.success) {
      Navigator.of(context).pop(feedback);
      return;
    }

    _showCustomNotification(feedback);
  }

  String? _requiredValidator(String? value) {
    return BusinessProfileFormHelper.requiredValidator(value);
  }

  String? _phoneValidator(String? value) {
    return BusinessProfileFormHelper.phoneValidator(value);
  }

  String? _documentValidator(String? value) {
    return BusinessProfileFormHelper.documentValidator(
      value: value,
      documentType: _editController.documentType,
    );
  }

  AppBar _buildAppBar(RolePalette palette) {
    return AppBar(
      backgroundColor: palette.background,
      surfaceTintColor: palette.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Editar perfil',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w900,
          color: palette.text,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 6.w),
          child: IconButton(
            onPressed: _logout,
            icon: Icon(
              Icons.logout_rounded,
              size: 22.sp,
              color: Colors.redAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(RolePalette palette) {
    return Center(child: CircularProgressIndicator(color: palette.primary));
  }

  Widget _buildBusinessDataSection(RolePalette palette) {
    return BusinessProfileEditSection(
      icon: Icons.storefront_rounded,
      title: 'Datos del negocio',
      subtitle: 'Información principal visible para clientes.',
      child: Column(
        children: [
          BusinessProfileField(
            controller: _editController.nameController,
            label: 'Nombre del negocio',
            icon: Icons.storefront_rounded,
            validator: _requiredValidator,
          ),
          DocumentTypeSelector(
            selectedType: _editController.documentType,
            isLoading: _editController.isSaving,
            enabled: _editController.canEditDocument,
            palette: palette,
            onChanged: _editController.updateDocumentType,
          ),
          if (_editController.isDocumentLocked) _buildLockedDocumentNotice(),
          BusinessProfileField(
            controller: _editController.documentNumberController,
            label: _editController.documentType == 'ruc'
                ? 'RUC (13 dígitos)'
                : 'Cédula (10 dígitos)',
            icon: Icons.badge_rounded,
            validator: _documentValidator,
            keyboardType: TextInputType.number,
            inputFormatters: _documentFormatters,
            enabled: _editController.canEditDocument,
          ),
          BusinessProfileField(
            controller: _editController.descriptionController,
            label: 'Descripción',
            icon: Icons.description_outlined,
            maxLines: 3,
            validator: _requiredValidator,
          ),
        ],
      ),
    );
  }

  Widget _buildLockedDocumentNotice() {
    const palette = RoleTheme.entrepreneur;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 8.h, bottom: 10.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: RoleTheme.iconColorFor(
              Icons.lock_outline_rounded,
              fallback: palette.primary,
            ),
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'El documento no se puede modificar después de la aprobación administrativa.',
              style: TextStyle(
                color: palette.mutedText,
                fontSize: 10.8.sp,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return BusinessProfileEditSection(
      icon: Icons.location_on_rounded,
      title: 'Contacto y atención',
      subtitle: 'Dirección, teléfono, correo y horarios de servicio.',
      child: Column(
        children: [
          BusinessProfileField(
            controller: _editController.addressController,
            label: 'Dirección',
            icon: Icons.location_on_rounded,
            validator: _requiredValidator,
          ),
          BusinessAddressLocationActions(
            hasMapLocation: _editController.hasMapLocation,
            onSelectLocation: _selectLocation,
          ),
          BusinessProfileField(
            controller: _editController.phoneController,
            label: 'Teléfono o WhatsApp del negocio',
            icon: Icons.phone_rounded,
            validator: _phoneValidator,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          BusinessProfileField(
            controller: _editController.emailController,
            label: 'Correo de contacto',
            icon: Icons.email_rounded,
            enabled: _editController.isPhoneRegister,
            keyboardType: TextInputType.emailAddress,
            validator: _editController.isPhoneRegister
                ? _editController.validateEmail
                : null,
          ),
          BusinessProfileField(
            controller: _editController.openingHoursController,
            label: 'Horarios de atención',
            icon: Icons.schedule_rounded,
            hintText:
                'Ejemplo:\nLunes a viernes: 08:00 - 18:00\nSábados: 09:00 - 13:00',
            maxLines: 4,
            keyboardType: TextInputType.multiline,
            validator: _requiredValidator,
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent({
    required String? currentImageUrl,
    required RolePalette palette,
  }) {
    return SafeArea(
      top: false,
      child: Form(
        key: _editController.formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 24.h),
          children: [
            BusinessEditProfileHeader(
              selectedImageFile: _editController.selectedImageFile,
              currentImageUrl: currentImageUrl,
              isUploadingImage: _editController.isUploadingImage,
              onPickImage: _pickImage,
            ),
            SizedBox(height: 12.h),
            const ProfileEmailVerificationCard(
              role: AppFeedbackRole.entrepreneur,
            ),
            SizedBox(height: 12.h),
            _buildBusinessDataSection(palette),
            SizedBox(height: 12.h),
            _buildContactSection(),
            SizedBox(height: 16.h),
            BusinessProfileSubmitButton(
              isSaving: _editController.isSaving,
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;
    final controller = context.watch<ProfileController>();

    return ListenableBuilder(
      listenable: _editController,
      builder: (context, _) {
        final currentImageUrl = controller.businessProfile?.profileImageUrl;
        final hasProfile = controller.businessProfile != null;

        return Scaffold(
          backgroundColor: palette.background,
          appBar: _buildAppBar(palette),
          body: controller.isLoading && !hasProfile
              ? _buildLoadingState(palette)
              : _buildFormContent(
                  currentImageUrl: currentImageUrl,
                  palette: palette,
                ),
        );
      },
    );
  }
}
