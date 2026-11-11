import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/auth/controllers/register_controller.dart';
import 'package:emprendedor/features/auth/helpers/register_validators.dart';
import 'package:emprendedor/presentation/auth/helpers/register_role_helper.dart';
import 'package:emprendedor/presentation/auth/pages/auth_wrapper.dart';
import 'package:emprendedor/presentation/auth/pages/login_page.dart';
import 'package:emprendedor/presentation/auth/pages/phone_auth_page.dart';
import 'package:emprendedor/presentation/auth/widgets/common/auth_screen_background.dart';
import 'package:emprendedor/presentation/auth/widgets/register/index.dart';
import 'package:emprendedor/presentation/client/profile/pages/client_profile_basic_form_page.dart';
import 'package:emprendedor/presentation/entrepreneur/profile/pages/index.dart';
import 'package:emprendedor/presentation/nutritionist/profile/pages/nutritionist_professional_registration_page.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const String _termsUrl =
      'https://edisontm1721.github.io/legal-app-saludable/terms.html';
  static const String _privacyUrl =
      'https://edisontm1721.github.io/legal-app-saludable/privacy.html';

  late final RegisterController _controller;
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  Widget _vGap(double value) => SizedBox(height: value.h);

  String get _selectedRole => _controller.selectedRole;
  String get _documentType => _controller.documentType;
  bool get _isLoading => _controller.isLoading;

  RolePalette get _currentPalette {
    return RegisterRoleHelper.palette(_selectedRole);
  }

  AppFeedbackRole get _feedbackRole {
    return RegisterRoleHelper.feedbackRole(_selectedRole);
  }

  @override
  void initState() {
    super.initState();

    _controller = RegisterController();

    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _openLegalUrl(_termsUrl);

    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _openLegalUrl(_privacyUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _openLegalUrl(String url) async {
    final opened = await _controller.openLegalUrl(url);

    if (!mounted) return;

    if (!opened) {
      _showFeedback('No se pudo abrir el enlace.', isError: true);
    }
  }

  void _showFeedback(String message, {required bool isError}) {
    if (!mounted) return;

    showAppMessage(
      context,
      role: _feedbackRole,
      type: isError ? AppFeedbackType.error : AppFeedbackType.success,
      title: isError ? 'No se pudo completar' : 'Listo',
      message: message,
    );
  }

  Future<void> _registerWithEmail() async {
    final completion = await _controller.registerWithEmail(
      onFeedback: _showFeedback,
    );

    await _navigateAfterRegister(completion);
  }

  Future<void> _registerWithGoogle() async {
    final completion = await _controller.registerWithGoogle(
      onFeedback: _showFeedback,
    );

    await _navigateAfterRegister(completion);
  }

  Future<void> _navigateAfterRegister(RegisterCompletion? completion) async {
    if (!mounted || completion == null) return;

    if (completion.shouldOpenAuthWrapper) {
      await AppNavigator.replaceAll(
        context,
        const AuthWrapper(),
        rootNavigator: true,
      );
      return;
    }

    await _goToPostRegisterForm(
      userId: completion.userId,
      selectedRole: completion.selectedRole,
    );
  }

  Future<void> _goToPostRegisterForm({
    required String userId,
    required String selectedRole,
  }) async {
    if (!mounted) return;

    final Widget destination;

    switch (selectedRole) {
      case 'cliente':
        destination = const ClientProfileBasicFormPage();
        break;

      case 'nutricionista':
        destination = const NutritionistProfessionalRegistrationPage();
        break;

      case 'emprendedor':
      default:
        destination = BusinessProfileSetupPage(userId: userId);
        break;
    }

    await AppNavigator.replaceAll(context, destination, rootNavigator: true);
  }

  void _navigateToPhoneRegister() {
    if (!mounted || _isLoading) return;

    AppNavigator.push(
      context,
      PhoneAuthPage(isLogin: false, selectedRole: _selectedRole),
    );
  }

  void _navigateToLogin() {
    if (!mounted || _isLoading) return;

    AppNavigator.replace(context, const LoginPage());
  }

  List<Widget> _buildErrorBox() {
    final message = _controller.errorMessage;

    if (message == null) return const [];

    return [_vGap(10), RegisterErrorBox(message: message)];
  }

  List<Widget> _buildRegisterContent() {
    return [
      RegisterHeader(selectedRole: _selectedRole),
      _vGap(11),
      RegisterFormCard(
        formKey: _controller.formKey,
        emailController: _controller.emailController,
        passwordController: _controller.passwordController,
        confirmPasswordController: _controller.confirmPasswordController,
        nameController: _controller.nameController,
        phoneController: _controller.phoneController,
        addressController: _controller.addressController,
        ageController: _controller.ageController,
        dietaryGoalController: _controller.dietaryGoalController,
        documentNumberController: _controller.documentNumberController,
        documentType: _documentType,
        businessDescriptionController:
        _controller.businessDescriptionController,
        specialtyController: _controller.specialtyController,
        licenseNumberController: _controller.licenseNumberController,
        professionalDescriptionController:
        _controller.professionalDescriptionController,
        selectedRole: _selectedRole,
        isLoading: _isLoading,
        termsRecognizer: _termsRecognizer,
        privacyRecognizer: _privacyRecognizer,
        onRoleChanged: _controller.updateSelectedRole,
        onDocumentTypeChanged: _controller.updateDocumentType,
        onRegister: _registerWithEmail,
        onClearError: _controller.clearError,
        validateEmail: RegisterValidators.email,
        validatePassword: RegisterValidators.password,
        validateConfirmPassword: (value) => RegisterValidators.confirmPassword(
          value,
          _controller.passwordController.text,
        ),
        validateRequired: RegisterValidators.requiredField,
        validatePhone: RegisterValidators.phone,
        validateAge: RegisterValidators.age,
        validateDocument: (value) =>
            RegisterValidators.document(value, _documentType),
        validateLicenseNumber: RegisterValidators.licenseNumber,
      ),
      ..._buildErrorBox(),
      _vGap(10),
      RegisterSocialButtons(
        selectedRole: _selectedRole,
        isLoading: _isLoading,
        onGoogleRegister: _registerWithGoogle,
        onPhoneRegister: _navigateToPhoneRegister,
        onLogin: _navigateToLogin,
      ),
    ];
  }

  Widget _buildPageBody(RolePalette palette) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: RegisterTopBar(
              palette: palette,
              isLoading: _isLoading,
              onBack: () => Navigator.of(context).pop(),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: _buildRegisterContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final palette = _currentPalette;

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          body: AuthScreenBackground(
            palette: palette,
            child: _buildPageBody(palette),
          ),
        );
      },
    );
  }
}