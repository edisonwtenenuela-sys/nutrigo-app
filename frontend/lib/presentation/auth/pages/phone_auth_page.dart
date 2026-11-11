import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/auth/controllers/phone_auth_controller.dart';
import 'package:emprendedor/presentation/auth/helpers/register_role_helper.dart';
import 'package:emprendedor/presentation/auth/pages/auth_wrapper.dart';
import 'package:emprendedor/presentation/auth/pages/login_page.dart';
import 'package:emprendedor/presentation/auth/pages/register_page.dart';
import 'package:emprendedor/presentation/auth/widgets/index.dart';
import 'package:emprendedor/presentation/client/profile/pages/client_profile_basic_form_page.dart';
import 'package:emprendedor/presentation/entrepreneur/profile/pages/index.dart';
import 'package:emprendedor/presentation/nutritionist/profile/pages/nutritionist_professional_registration_page.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class PhoneAuthPage extends StatefulWidget {
  final bool isLogin;
  final String selectedRole;

  const PhoneAuthPage({
    super.key,
    required this.isLogin,
    this.selectedRole = 'emprendedor',
  });

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  late final PhoneAuthController _controller;

  Widget _vGap(double value) => SizedBox(height: value.h);

  AppFeedbackRole get _feedbackRole {
    return RegisterRoleHelper.feedbackRole(widget.selectedRole);
  }

  RolePalette get _rolePalette {
    if (widget.isLogin) return RoleTheme.client;
    return RegisterRoleHelper.palette(widget.selectedRole);
  }

  @override
  void initState() {
    super.initState();

    _controller = PhoneAuthController(
      isLogin: widget.isLogin,
      selectedRole: widget.selectedRole,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  Future<void> _sendVerificationCode() async {
    await _controller.sendVerificationCode(
      onVerificationCompleted: _completePhoneSignIn,
      onFeedback: _showFeedback,
    );
  }

  Future<void> _verifyOtp() async {
    final completion = await _controller.verifyOtp(onFeedback: _showFeedback);
    await _navigateAfterCompletion(completion);
  }

  Future<void> _completePhoneSignIn(PhoneAuthSignInResult result) async {
    final completion = await _controller.completePhoneSignIn(
      result: result,
      onFeedback: _showFeedback,
    );

    await _navigateAfterCompletion(completion);
  }

  Future<void> _navigateAfterCompletion(PhoneAuthCompletion? completion) async {
    if (!mounted || completion == null) return;

    switch (completion.destination) {
      case PhoneAuthDestination.clientProfile:
        await AppNavigator.replaceAll(
          context,
          const ClientProfileBasicFormPage(),
          rootNavigator: true,
        );
        return;

      case PhoneAuthDestination.entrepreneurSetup:
        await AppNavigator.replaceAll(
          context,
          BusinessProfileSetupPage(userId: completion.userId),
          rootNavigator: true,
        );
        return;

      case PhoneAuthDestination.nutritionistRegistration:
        await AppNavigator.replaceAll(
          context,
          const NutritionistProfessionalRegistrationPage(),
          rootNavigator: true,
        );
        return;

      case PhoneAuthDestination.authWrapper:
        await AppNavigator.replaceAll(
          context,
          const AuthWrapper(),
          rootNavigator: true,
        );
        return;
    }
  }

  AppBar _buildAppBar(RolePalette palette) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      centerTitle: true,
      backgroundColor: palette.background,
      surfaceTintColor: palette.background,
      foregroundColor: palette.text,
      title: Text(
        'Verificación SMS',
        style: TextStyle(
          color: palette.text,
          fontSize: 18.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  void _returnToPreviousAuthStep() {
    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    final fallbackPage = widget.isLogin
        ? const LoginPage()
        : const RegisterPage();

    AppNavigator.replace(context, fallbackPage);
  }

  Widget _buildBackToLoginButton(RolePalette palette) {
    final label = widget.isLogin
        ? 'Volver al inicio de sesión'
        : 'Volver a crear cuenta';

    return TextButton.icon(
      onPressed: _controller.isLoading ? null : _returnToPreviousAuthStep,
      icon: Icon(
        Icons.arrow_back_rounded,
        color: RoleTheme.iconColorFor(
          Icons.arrow_back_rounded,
          fallback: palette.primary,
        ),
        size: 17.sp,
      ),
      label: Text(
        label,
        style: TextStyle(fontSize: 12.8.sp, fontWeight: FontWeight.w900),
      ),
      style: TextButton.styleFrom(
        foregroundColor: palette.primary,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      ),
    );
  }

  Widget _buildPhoneAccessCard(RolePalette palette) {
    return PhoneAccessCard(
      isLogin: widget.isLogin,
      selectedRole: widget.selectedRole,
      isLoading: _controller.isLoading,
      otpSent: _controller.otpSent,
      verificationId: _controller.verificationId,
      palette: palette,
      documentType: _controller.documentType,
      documentDigitLimit: _controller.documentDigitLimit,
      phoneController: _controller.phoneController,
      otpController: _controller.otpController,
      nameController: _controller.nameController,
      addressController: _controller.addressController,
      ageController: _controller.ageController,
      dietaryGoalController: _controller.dietaryGoalController,
      documentNumberController: _controller.documentNumberController,
      businessDescriptionController: _controller.businessDescriptionController,
      specialtyController: _controller.specialtyController,
      licenseNumberController: _controller.licenseNumberController,
      professionalDescriptionController:
      _controller.professionalDescriptionController,
      nutritionistEmailController: _controller.nutritionistEmailController,
      contactEmailController: _controller.contactEmailController,
      onSendCode: _sendVerificationCode,
      onVerifyOtp: _verifyOtp,
      onDocumentTypeChanged: _controller.changeDocumentType,
    );
  }

  List<Widget> _buildErrorBlock() {
    final message = _controller.errorMessage;

    if (message == null) return const [];

    return [_vGap(16), PhoneAuthError(message: message)];
  }

  Widget _buildScreenContent(BoxConstraints constraints, RolePalette palette) {
    final isCodeStep = _controller.otpSent;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(18.w, isCodeStep ? 6.h : 10.h, 18.w, 18.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Transform.translate(
          offset: Offset(0, -10.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PhoneAuthHeader(
                isLogin: widget.isLogin,
                selectedRole: widget.selectedRole,
                currentStep: _controller.smsCurrentStep,
              ),
              _vGap(isCodeStep ? 10 : 16),
              _buildPhoneAccessCard(palette),
              ..._buildErrorBlock(),
              _vGap(isCodeStep ? 12 : 18),
              _buildBackToLoginButton(palette),
              _vGap(10),
              _PhoneTrustFooter(palette: palette),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageBody(RolePalette palette) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return _buildScreenContent(constraints, palette);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final palette = _rolePalette;

        return Scaffold(
          backgroundColor: palette.background,
          appBar: _buildAppBar(palette),
          body: _buildPageBody(palette),
        );
      },
    );
  }
}

class _PhoneTrustFooter extends StatelessWidget {
  final RolePalette palette;

  const _PhoneTrustFooter({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _PhoneTrustItem(
            icon: Icons.sms_outlined,
            label: 'Código SMS',
            palette: palette,
          ),
          _PhoneTrustDivider(palette: palette),
          _PhoneTrustItem(
            icon: Icons.lock_outline_rounded,
            label: 'Acceso seguro',
            palette: palette,
          ),
          _PhoneTrustDivider(palette: palette),
          _PhoneTrustItem(
            icon: Icons.verified_outlined,
            label: 'Verificado',
            palette: palette,
          ),
        ],
      ),
    );
  }
}

class _PhoneTrustItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final RolePalette palette;

  const _PhoneTrustItem({
    required this.icon,
    required this.label,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
          size: 14.sp,
        ),
        SizedBox(width: 5.w),
        Text(
          label,
          style: TextStyle(
            color: palette.text.withValues(alpha: 0.78),
            fontSize: 10.3.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _PhoneTrustDivider extends StatelessWidget {
  final RolePalette palette;

  const _PhoneTrustDivider({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.w,
      height: 16.h,
      color: palette.primary.withValues(alpha: 0.11),
    );
  }
}