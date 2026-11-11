import 'package:flutter/material.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/client/controllers/client_profile_controller.dart';
import 'package:emprendedor/features/client/controllers/client_profile_edit_controller.dart';
import 'package:emprendedor/features/client/controllers/client_location_picker_controller.dart';
import 'package:emprendedor/presentation/client/cart/pages/select_location_page.dart';
import 'package:emprendedor/presentation/client/profile/widgets/index.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class ClientProfileEditPage extends StatefulWidget {
  const ClientProfileEditPage({super.key});

  @override
  State<ClientProfileEditPage> createState() => _ClientProfileEditPageState();
}

class _ClientProfileEditPageState extends State<ClientProfileEditPage> {
  late final ClientProfileEditController _editController;
  bool _initialized = false;

  Widget _vGap(double value) => SizedBox(height: value.h);

  @override
  void initState() {
    super.initState();
    _editController = ClientProfileEditController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final controller = context.read<ClientProfileController>();
    _editController.observe(controller);

    if (_initialized) return;
    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      controller.clearError();
      await _editController.ensureProfileLoaded(controller);
    });
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  Future<void> _selectLocation(ClientProfileController controller) async {
    final result = await AppNavigator.push<SelectedLocationResult>(
      context,
      const SelectLocationPage(),
    );

    if (!mounted || result == null) return;
    _editController.applyLocation(controller, result);
  }

  Future<void> _save(ClientProfileController controller) async {
    final success = await _editController.saveIfChanged(controller);

    if (!mounted || !success) return;

    await showAppMessage(
      context,
      role: AppFeedbackRole.client,
      type: AppFeedbackType.success,
      title: 'Perfil guardado',
      message: 'Tu información se actualizó correctamente.',
    );

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  AppBar _buildAppBar(RolePalette palette) {
    return AppBar(
      backgroundColor: palette.background,
      surfaceTintColor: palette.background,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: palette.text),
      title: Text(
        'Editar perfil',
        style: TextStyle(
          color: palette.text,
          fontSize: 19.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildPersonalSection(ClientProfileController controller) {
    return ClientProfileSection(
      title: 'Datos personales',
      icon: Icons.badge_rounded,
      children: [
        ProfileField(
          controller: controller.nameController,
          label: 'Nombre completo',
          icon: Icons.person_rounded,
          validator: (value) => controller.validateRequired(value, 'tu nombre'),
        ),
        _vGap(10),
        if (_editController.isPhoneRegister) ...[
          ProfileField(
            controller: controller.emailController,
            label: 'Correo de contacto',
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: _editController.validateEmail,
          ),
          const ClientProfileHelperText(
            'Usaremos este correo para recuperación y notificaciones.',
          ),
          _vGap(10),
        ],
        ProfileField(
          controller: controller.phoneController,
          label: 'Teléfono de contacto',
          icon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: controller.validatePhone,
        ),
        const ClientProfileHelperText(
          'Puede ser el mismo número de acceso u otro para entregas.',
        ),
        _vGap(10),
        ProfileField(
          controller: controller.ageController,
          label: 'Edad',
          icon: Icons.cake_rounded,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          validator: controller.validateAge,
        ),
        _vGap(10),
        ClientGenderDropdown(controller: controller),
      ],
    );
  }

  Widget _buildDeliverySection(
    ClientProfileController controller,
    RolePalette palette,
  ) {
    return ClientProfileSection(
      title: 'Entrega y objetivo',
      icon: Icons.flag_rounded,
      children: [
        ProfileField(
          controller: controller.addressController,
          label: 'Dirección',
          icon: Icons.location_on_rounded,
          readOnly: true,
          validator: (value) =>
              controller.validateRequired(value, 'tu dirección'),
        ),
        ClientProfileSelectLocationButton(
          isSaving: controller.isSaving,
          onPressed: () => _selectLocation(controller),
        ),
        ClientGoalDropdown(
          goals: ClientProfileEditController.goals,
          controller: controller,
        ),
        const ClientProfileHelperText(
          'Este dato permite orientar mejor las recomendaciones dentro de la app.',
        ),
      ],
    );
  }

  Widget _buildHealthSection(ClientProfileController controller) {
    return ClientProfileSection(
      title: 'Salud y preferencias',
      icon: Icons.favorite_border_rounded,
      children: [
        ProfileField(
          controller: controller.weightController,
          label: 'Peso (kg)',
          icon: Icons.monitor_weight_outlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            LengthLimitingTextInputFormatter(6),
          ],
        ),
        _vGap(10),
        ProfileField(
          controller: controller.heightController,
          label: 'Estatura (cm)',
          icon: Icons.height_rounded,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            LengthLimitingTextInputFormatter(6),
          ],
        ),
        _vGap(10),
        ClientProfileAllergies(controller: controller),
      ],
    );
  }

  List<Widget> _buildErrorBlock(ClientProfileController controller) {
    if (controller.errorMessage == null) return const [];

    return [
      _vGap(12),
      ClientProfileErrorCard(message: controller.errorMessage!),
    ];
  }

  Widget _buildForm(ClientProfileController controller, RolePalette palette) {
    final hasChanges = _editController.hasChanges(controller);

    return Form(
      key: controller.formKey,
      child: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 24.h),
        children: [
          ClientProfileRegistrationHeader(),
          _vGap(14),
          _buildPersonalSection(controller),
          _vGap(12),
          _buildDeliverySection(controller, palette),
          _vGap(12),
          _buildHealthSection(controller),
          _vGap(12),
          const ClientProfilePrivacyNote(),
          ..._buildErrorBlock(controller),
          _vGap(18),
          ClientProfileInlineSaveButton(
            isSaving: controller.isSaving,
            onSave: hasChanges ? () => _save(controller) : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ClientProfileController>();
    const palette = RoleTheme.client;

    return ListenableBuilder(
      listenable: _editController,
      builder: (context, _) {
        final uiState = _editController.resolveUiState(controller);

        return Scaffold(
          backgroundColor: palette.background,
          resizeToAvoidBottomInset: true,
          appBar: _buildAppBar(palette),
          body: SafeArea(
            child: switch (uiState) {
              ClientProfileEditUiState.loading =>
                const ClientProfileEditLoadingView(),
              ClientProfileEditUiState.content => _buildForm(
                controller,
                palette,
              ),
            },
          ),
        );
      },
    );
  }
}
