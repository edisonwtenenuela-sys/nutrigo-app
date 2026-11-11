import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/product_controller.dart';
import 'package:emprendedor/features/nutritionist/controllers/index.dart';
import 'package:emprendedor/presentation/nutritionist/home/widgets/nutritionist_home_header.dart';
import 'package:emprendedor/presentation/nutritionist/home/widgets/nutritionist_professional_info_card.dart';
import 'package:emprendedor/presentation/nutritionist/home/widgets/nutritionist_summary_card.dart';
import 'package:emprendedor/presentation/nutritionist/profile/pages/nutritionist_professional_registration_page.dart';

class NutritionistHomePage extends StatefulWidget {
  final bool isVerified;

  const NutritionistHomePage({super.key, required this.isVerified});

  @override
  State<NutritionistHomePage> createState() => _NutritionistHomePageState();
}

class _NutritionistHomePageState extends State<NutritionistHomePage> {
  bool _loaded = false;

  Widget _vGap(double value) => SizedBox(height: value.h);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loaded) return;

    _loaded = true;
    _scheduleDashboardRefresh();
  }

  @override
  void didUpdateWidget(covariant NutritionistHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isVerified && widget.isVerified) {
      _scheduleDashboardRefresh();
    }
  }

  void _scheduleDashboardRefresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshDashboard();
    });
  }

  Future<void> _openProfessionalForm() async {
    await AppNavigator.push(
      context,
      const NutritionistProfessionalRegistrationPage(allowBack: true),
    );

    if (!mounted) return;

    await _refreshDashboard();
  }

  Future<void> _refreshDashboard() async {
    final profileController = context.read<NutritionistProfileController>();

    final futures = <Future<void>>[profileController.loadProfile()];

    if (widget.isVerified) {
      final appointmentsController = context
          .read<NutritionistAppointmentsController>();
      final patientsController = context.read<NutritionistPatientsController>();
      final productController = context.read<ProductController>();

      futures.addAll([
        appointmentsController.initUser(),
        patientsController.loadPatients(),
        productController.fetchPendingProductsForNutritionist(),
      ]);
    }

    await Future.wait(futures);
  }

  _DashboardMetrics _resolveMetrics({
    required NutritionistAppointmentsController appointmentsController,
    required NutritionistPatientsController patientsController,
    required ProductController productController,
  }) {
    if (!widget.isVerified) {
      return const _DashboardMetrics(
        appointmentCount: 0,
        patientCount: 0,
        pendingValidationCount: 0,
      );
    }

    final pendingValidationCount = productController.allProducts.where((
      product,
    ) {
      return product.validationStatus == NutritionValidationStatus.pending;
    }).length;

    return _DashboardMetrics(
      appointmentCount: appointmentsController.appointments.length,
      patientCount: patientsController.patients.length,
      pendingValidationCount: pendingValidationCount,
    );
  }

  Widget _buildSummarySection({
    required RolePalette palette,
    required int appointmentCount,
    required int patientCount,
    required int pendingValidationCount,
    required bool isRejected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen profesional',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: palette.text,
          ),
        ),
        _vGap(10),
        Row(
          children: [
            Expanded(
              child: NutritionistSummaryCard(
                title: 'Citas',
                value: appointmentCount.toString(),
                icon: Icons.calendar_month_rounded,
                color: RoleTheme.iconColorFor(
                  Icons.calendar_month_rounded,
                  fallback: palette.primary,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: NutritionistSummaryCard(
                title: 'Pacientes',
                value: patientCount.toString(),
                icon: Icons.groups_rounded,
                color: RoleTheme.iconColorFor(
                  Icons.groups_rounded,
                  fallback: palette.primary,
                ),
              ),
            ),
          ],
        ),
        _vGap(10),
        Row(
          children: [
            Expanded(
              child: NutritionistSummaryCard(
                title: 'Validaciones',
                value: pendingValidationCount.toString(),
                icon: Icons.verified_rounded,
                color: RoleTheme.iconColorFor(
                  Icons.verified_rounded,
                  fallback: palette.primary,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: NutritionistSummaryCard(
                title: 'Estado',
                value: widget.isVerified
                    ? 'Activo'
                    : isRejected
                    ? 'Rechazado'
                    : 'Pendiente',
                icon: widget.isVerified
                    ? Icons.check_circle_rounded
                    : isRejected
                    ? Icons.cancel_rounded
                    : Icons.lock_clock_rounded,
                color: widget.isVerified
                    ? RoleTheme.iconValidation
                    : isRejected
                    ? RoleTheme.iconDanger
                    : RoleTheme.iconWarning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<NutritionistProfileController>();
    final appointmentsController = context
        .watch<NutritionistAppointmentsController>();
    final patientsController = context.watch<NutritionistPatientsController>();
    final productController = context.watch<ProductController>();

    final profile = profileController.currentProfile;
    final isResolvingProfessionalStatus =
        profileController.isLoadingProfile && profile == null;

    final metrics = _resolveMetrics(
      appointmentsController: appointmentsController,
      patientsController: patientsController,
      productController: productController,
    );

    const palette = RoleTheme.nutritionist;

    return RefreshIndicator(
      color: palette.primary,
      onRefresh: _refreshDashboard,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 18.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NutritionistHomeHeader(
              name: profile?.name ?? '',
              specialty: profile?.specialty ?? '',
              imageUrl: profile?.profileImageUrl,
            ),
            _vGap(14),
            NutritionistProfessionalInfoCard(
              specialty: profile?.specialty,
              consultationMode: profile?.consultationMode.name,
              consultationPrice: profile?.consultationPrice,
              isVerified: widget.isVerified,
              isResolvingStatus: isResolvingProfessionalStatus,
              isRejected: profileController.isRejected,
              rejectionMessage: profile?.verificationMessage,
              onEditPressed: widget.isVerified || isResolvingProfessionalStatus
                  ? null
                  : _openProfessionalForm,
            ),
            _vGap(16),
            _buildSummarySection(
              palette: palette,
              appointmentCount: metrics.appointmentCount,
              patientCount: metrics.patientCount,
              pendingValidationCount: metrics.pendingValidationCount,
              isRejected: profileController.isRejected,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardMetrics {
  final int appointmentCount;
  final int patientCount;
  final int pendingValidationCount;

  const _DashboardMetrics({
    required this.appointmentCount,
    required this.patientCount,
    required this.pendingValidationCount,
  });
}
