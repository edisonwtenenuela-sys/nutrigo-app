import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/features/admin/controllers/nutritionist_verification_controller.dart';
import 'package:emprendedor/features/admin/controllers/admin_history_controller.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/admin/nutritionist_verification_request_model.dart';
import 'package:emprendedor/presentation/admin/widgets/index.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class NutritionistVerificationPage extends StatefulWidget {
  const NutritionistVerificationPage({super.key});

  @override
  State<NutritionistVerificationPage> createState() =>
      _NutritionistVerificationPageState();
}

class _NutritionistVerificationPageState
    extends State<NutritionistVerificationPage> {
  late final NutritionistVerificationController _controller;
  late final NutritionistVerificationScreenController _screenController;

  _NutritionistRequestsUiState _resolveUiState() {
    final hasRequests = _controller.requests.isNotEmpty;
    if (_controller.isLoading && !hasRequests) {
      return _NutritionistRequestsUiState.loading;
    }
    if (!hasRequests) return _NutritionistRequestsUiState.empty;
    return _NutritionistRequestsUiState.ready;
  }

  @override
  void initState() {
    super.initState();
    _controller = NutritionistVerificationController();
    _screenController = NutritionistVerificationScreenController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.listenPendingRequests();
      _screenController.loadDiagnostics();
    });
  }

  @override
  void dispose() {
    _screenController.dispose();
    _controller.dispose();
    super.dispose();
  }

  String _requestResultMessage({
    required bool ok,
    required String successMessage,
    required String fallbackErrorMessage,
  }) {
    if (ok) return successMessage;
    return _controller.errorMessage ?? fallbackErrorMessage;
  }

  Future<void> _approve(NutritionistVerificationRequestModel request) async {
    final canReview = await _controller.canReviewRequest(request);
    if (!mounted) return;
    if (!canReview) {
      _showFeedback(
        _controller.errorMessage ?? 'No se pudo revisar la solicitud.',
        isError: true,
      );
      return;
    }

    final ok = await _controller.approveRequest(request);
    if (!mounted) return;
    _showFeedback(
      _requestResultMessage(
        ok: ok,
        successMessage: 'Nutricionista aprobado correctamente.',
        fallbackErrorMessage: 'Error al aprobar.',
      ),
      isError: !ok,
    );
  }

  Future<void> _reject(NutritionistVerificationRequestModel request) async {
    final canReview = await _controller.canReviewRequest(request);
    if (!mounted) return;
    if (!canReview) {
      _showFeedback(
        _controller.errorMessage ?? 'No se pudo revisar la solicitud.',
        isError: true,
      );
      return;
    }

    final reason = await showRejectionReasonDialog(
      context,
      title: 'Rechazar nutricionista',
      subject: 'el nutricionista',
      hintText:
          'Ej: El registro profesional no coincide o falta completar la especialidad.',
    );

    if (reason == null || !mounted) return;

    final ok = await _controller.rejectRequest(request, reason: reason);
    if (!mounted) return;
    _showFeedback(
      _requestResultMessage(
        ok: ok,
        successMessage: 'Solicitud de nutricionista rechazada.',
        fallbackErrorMessage: 'Error al rechazar.',
      ),
      isError: !ok,
    );
  }

  void _showFeedback(String message, {bool isError = false}) {
    showAppMessage(
      context,
      role: AppFeedbackRole.admin,
      type: isError ? AppFeedbackType.error : AppFeedbackType.success,
      title: isError ? 'No se pudo completar' : 'Solicitud actualizada',
      message: message,
    );
  }

  bool _isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 600;
  }

  AppBar _buildAppBar(bool isTablet, RolePalette palette) {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      backgroundColor: palette.surface,
      surfaceTintColor: palette.surface,
      title: Text(
        'Verificar nutricionistas',
        style: TextStyle(
          fontSize: isTablet ? 20 : 19.sp,
          fontWeight: FontWeight.w900,
          color: palette.text,
        ),
      ),
    );
  }

  Widget _buildBody(bool isTablet, RolePalette palette) {
    final errorMessage = _controller.errorMessage;
    if (errorMessage != null && _controller.requests.isEmpty) {
      return _NutritionistRequestsErrorState(
        message: errorMessage,
        onRetry: _controller.listenPendingRequests,
        diagnostics: _screenController.diagnostics,
      );
    }

    final uiState = _resolveUiState();

    if (uiState == _NutritionistRequestsUiState.loading) {
      return _buildLoadingState(palette);
    }

    if (uiState == _NutritionistRequestsUiState.empty) {
      return const NutritionistVerificationEmptyState();
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isTablet ? 720 : double.infinity),
        child: ListView.separated(
          padding: EdgeInsets.all(isTablet ? 24 : 16.w),
          itemCount: _controller.requests.length,
          separatorBuilder: (context, index) =>
              SizedBox(height: isTablet ? 14 : 12.h),
          itemBuilder: (context, index) {
            final request = _controller.requests[index];
            return NutritionistVerificationRequestCard(
              request: request,
              onApprove: () => _approve(request),
              onReject: () => _reject(request),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState(RolePalette palette) {
    return Center(child: CircularProgressIndicator(color: palette.primary));
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    const palette = RoleTheme.admin;

    return ListenableBuilder(
      listenable: _screenController,
      builder: (context, _) {
        return ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return Scaffold(
              backgroundColor: palette.background,
              appBar: _buildAppBar(isTablet, palette),
              body: _buildBody(isTablet, palette),
            );
          },
        );
      },
    );
  }
}

enum _NutritionistRequestsUiState { loading, empty, ready }

class _NutritionistRequestsErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final Map<String, String> diagnostics;

  const _NutritionistRequestsErrorState({
    required this.message,
    required this.onRetry,
    required this.diagnostics,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: RoleTheme.iconDanger,
              size: 48.sp,
            ),
            SizedBox(height: 10.h),
            Text(
              'No se pudieron cargar las solicitudes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w900,
                color: RoleTheme.admin.text,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: RoleTheme.iconDanger,
              ),
            ),
            if (diagnostics.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: RoleTheme.admin.surface,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'projectId: ${diagnostics['projectId'] ?? '-'}\n'
                  'uid: ${diagnostics['uid'] ?? '-'}\n'
                  'email: ${diagnostics['email'] ?? '-'}\n'
                  'role: ${diagnostics['role'] ?? diagnostics['error'] ?? '-'}',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    color: RoleTheme.admin.mutedText,
                  ),
                ),
              ),
            ],
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
