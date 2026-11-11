import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/auth/controllers/auth_session_controller.dart';
import 'package:emprendedor/features/client/controllers/client_location_picker_controller.dart';
import 'package:emprendedor/features/client/controllers/client_profile_controller.dart';
import 'package:emprendedor/presentation/auth/pages/auth_wrapper.dart';
import 'package:emprendedor/presentation/client/cart/pages/select_location_page.dart';
import 'package:emprendedor/presentation/client/profile/widgets/index.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';
import 'package:emprendedor/presentation/shared/widgets/registration_form_loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ClientProfileBasicFormPage extends StatefulWidget {
  const ClientProfileBasicFormPage({super.key});

  @override
  State<ClientProfileBasicFormPage> createState() =>
      _ClientProfileBasicFormPageState();
}

class _ClientProfileBasicFormPageState
    extends State<ClientProfileBasicFormPage> {
  final AuthSessionController _sessionController = AuthSessionController();

  bool _initialized = false;

  Widget _vGap(double value) => SizedBox(height: value.h);

  final List<String> _goals = const [
    'Perder peso',
    'Ganar masa muscular',
    'Mejorar salud',
    'Mantener peso',
    'Aumentar energía',
    'Alimentación balanceada',
  ];

  bool get _isPhoneRegister {
    return _sessionController.currentSnapshot()?.isPhoneOnly ?? false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ClientProfileController>().loadProfile();
    });
  }

  Future<void> _selectLocation(ClientProfileController controller) async {
    final result = await AppNavigator.push<SelectedLocationResult>(
      context,
      const SelectLocationPage(),
    );

    if (!mounted || result == null) return;

    controller.setSelectedLocation(
      address: result.address,
      latitude: result.latitude,
      longitude: result.longitude,
    );
  }

  Future<void> _save(ClientProfileController controller) async {
    final success = await controller.saveProfile();

    if (!mounted) return;

    if (success) {
      await showAppMessage(
        context,
        role: AppFeedbackRole.client,
        type: AppFeedbackType.success,
        title: 'Perfil guardado',
        message: 'Tu información básica se guardó correctamente.',
      );

      if (!mounted) return;

      AppNavigator.replaceAll(context, const AuthWrapper());
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) return 'Ingresa tu correo electrónico';

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    if (!emailRegex.hasMatch(email)) {
      return 'Ingresa un correo válido';
    }

    return null;
  }

  AppBar _buildAppBar(RolePalette palette) {
    return AppBar(
      backgroundColor: palette.background,
      surfaceTintColor: palette.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Completa tu perfil',
        style: TextStyle(
          color: palette.text,
          fontSize: 19.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildPersonalDataSection(ClientProfileController controller) {
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
        if (_isPhoneRegister) ...[
          ProfileField(
            controller: controller.emailController,
            label: 'Correo de contacto',
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
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
          goals: _goals,
          controller: controller,
        ),
      ],
    );
  }

  Widget _buildFormBody(
      ClientProfileController controller,
      RolePalette palette,
      ) {
    return SafeArea(
      child: Form(
        key: controller.formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 24.h),
          children: [
            ClientProfileRegistrationHeader(),
            _vGap(14),
            _buildPersonalDataSection(controller),
            _vGap(12),
            _buildDeliverySection(controller, palette),
            _vGap(18),
            ClientProfileInlineSaveButton(
              isSaving: controller.isSaving,
              onSave: () => _save(controller),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ClientProfileController>();
    const palette = RoleTheme.client;

    if (controller.isLoading) {
      return const _ClientProfileSetupLoadingView();
    }

    return Scaffold(
      backgroundColor: palette.background,
      appBar: _buildAppBar(palette),
      body: _buildFormBody(controller, palette),
    );
  }
}

class _ClientProfileSetupLoadingView extends StatelessWidget {
  const _ClientProfileSetupLoadingView();

  @override
  Widget build(BuildContext context) {
    return const RegistrationFormLoadingView(
      palette: RoleTheme.client,
      icon: Icons.person_search_rounded,
      eyebrow: 'PERFIL CLIENTE',
      title: 'Formulario de cliente',
      message: 'Completa tus datos.',
      steps: ['Datos personales', 'Preferencias', 'Ubicación'],
    );
  }
}