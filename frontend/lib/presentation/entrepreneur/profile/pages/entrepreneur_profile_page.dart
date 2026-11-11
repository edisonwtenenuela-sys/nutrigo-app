import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/business_profile_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';
import 'package:emprendedor/presentation/entrepreneur/profile/pages/index.dart';
import 'package:emprendedor/presentation/entrepreneur/profile/widgets/index.dart';

class BusinessProfilePage extends StatefulWidget {
  const BusinessProfilePage({
    super.key,
    this.onEditProfile,
    this.onPaymentMethods,
    this.onSocialMedia,
  });

  final Future<void> Function()? onEditProfile;
  final Future<void> Function()? onPaymentMethods;
  final Future<void> Function()? onSocialMedia;

  @override
  State<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  final BusinessProfileScreenController _screenController =
      BusinessProfileScreenController();

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initProfile();
  }

  Future<void> _initProfile() async {
    if (_initialized) return;
    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _screenController.load(
        profileController: context.read<ProfileController>(),
        socialController: context.read<SocialMediaController>(),
        paymentController: context.read<PaymentMethodController>(),
      );
    });
  }

  Future<void> _refreshProfile() async {
    await _screenController.refresh(
      profileController: context.read<ProfileController>(),
      socialController: context.read<SocialMediaController>(),
      paymentController: context.read<PaymentMethodController>(),
    );
  }

  Future<void> _goToEditPage() async {
    final userId = _screenController.currentUserId();
    if (userId == null) return;

    await AppNavigator.push(context, BusinessProfileEditPage(userId: userId));

    if (!mounted) return;
    await _refreshProfile();
  }

  Future<void> _runQuickAction(Future<void> Function()? action) async {
    if (action == null) return;

    await action();

    if (!mounted) return;
    await _refreshProfile();
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        const BusinessProfileSectionTitle(
          icon: Icons.tune_rounded,
          title: 'Gestiona tu perfil',
          subtitle: 'Completa y actualiza la información de tu negocio.',
        ),
        BusinessProfileQuickActionCard(
          icon: Icons.edit_rounded,
          title: 'Editar perfil',
          subtitle: 'Actualiza datos públicos, logo, ubicación y horarios.',
          onTap: () {
            if (widget.onEditProfile != null) {
              _runQuickAction(widget.onEditProfile);
              return;
            }

            _goToEditPage();
          },
        ),
        if (widget.onSocialMedia != null)
          BusinessProfileQuickActionCard(
            icon: Icons.public_rounded,
            title: 'Redes sociales',
            subtitle: 'Agrega tus canales de contacto y sitio web.',
            onTap: () => _runQuickAction(widget.onSocialMedia),
          ),
        if (widget.onPaymentMethods != null)
          BusinessProfileQuickActionCard(
            icon: Icons.payments_rounded,
            title: 'Métodos de pago',
            subtitle: 'Configura las opciones disponibles para tus clientes.',
            onTap: () => _runQuickAction(widget.onPaymentMethods),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    const palette = RoleTheme.entrepreneur;

    return Center(child: CircularProgressIndicator(color: palette.primary));
  }

  Widget _buildErrorState(String message) {
    return ProfileStateMessage(
      icon: Icons.error_outline_rounded,
      title: 'No se pudo cargar el perfil',
      message: message,
      buttonText: 'Reintentar',
      onPressed: _refreshProfile,
    );
  }

  Widget _buildEmptyState() {
    return ProfileStateMessage(
      icon: Icons.storefront_outlined,
      title: 'Perfil no configurado',
      message:
          'Agrega los datos de tu negocio para que los clientes puedan conocerte mejor.',
      buttonText: 'Crear perfil',
      onPressed: _goToEditPage,
    );
  }

  Widget _buildContent({
    required BusinessProfileModel profile,
    required SocialMediaController socialController,
    required PaymentMethodController paymentController,
  }) {
    const palette = RoleTheme.entrepreneur;

    return RefreshIndicator(
      color: palette.primary,
      onRefresh: _refreshProfile,
      child: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 96.h),
        children: [
          BusinessProfileHeader(profile: profile),
          SizedBox(height: 12.h),
          BusinessProfileCompletionCard(
            profile: profile,
            hasPaymentMethods: paymentController.paymentMethods.isNotEmpty,
            hasSocialMedia: _screenController.hasSocialMedia(socialController),
          ),
          SizedBox(height: 12.h),
          _buildQuickActions(),
          SizedBox(height: 12.h),
          const BusinessProfileSectionTitle(
            icon: Icons.visibility_rounded,
            title: 'Información visible para clientes',
            subtitle: 'Datos principales que veran tus clientes.',
          ),
          CompactProfileInfoCard(
            description: profile.description,
            address: profile.address,
            phone: profile.phone,
            openingHours: profile.openingHours,
          ),
          SizedBox(height: 12.h),
          BusinessProfileSocialLinks(
            socialMediaList: socialController.socialMediaList,
          ),
          SizedBox(height: 12.h),
          BusinessReviewsPreview(businessUserId: profile.userId ?? ''),
        ],
      ),
    );
  }

  Widget _buildPageBody({
    required ProfileController profileController,
    required SocialMediaController socialController,
    required PaymentMethodController paymentController,
  }) {
    final uiState = _screenController.resolveUiState(profileController);

    if (uiState == BusinessProfileUiState.sessionMissing) {
      return _buildErrorState('No hay una sesión activa.');
    }

    if (uiState == BusinessProfileUiState.loading) {
      return _buildLoadingState();
    }

    if (uiState == BusinessProfileUiState.error) {
      return _buildErrorState(profileController.errorMessage!);
    }

    if (uiState == BusinessProfileUiState.empty) {
      return _buildEmptyState();
    }

    return _buildContent(
      profile: profileController.businessProfile!,
      socialController: socialController,
      paymentController: paymentController,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();
    final socialController = context.watch<SocialMediaController>();
    final paymentController = context.watch<PaymentMethodController>();

    return _buildPageBody(
      profileController: profileController,
      socialController: socialController,
      paymentController: paymentController,
    );
  }
}








