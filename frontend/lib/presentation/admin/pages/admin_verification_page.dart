import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/features/admin/controllers/admin_verification_controller.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/admin/admin_verification_request_model.dart';
import 'package:emprendedor/presentation/admin/widgets/index.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class AdminVerificationPage extends StatefulWidget {
  const AdminVerificationPage({super.key});

  @override
  State<AdminVerificationPage> createState() => _AdminVerificationPageState();
}

class _AdminVerificationPageState extends State<AdminVerificationPage> {
  late final AdminVerificationController _controller;

  _AdminRequestsUiState _resolveUiState() {
    final hasRequests = _controller.requests.isNotEmpty;
    if (_controller.isLoading && !hasRequests) {
      return _AdminRequestsUiState.loading;
    }
    if (!hasRequests) return _AdminRequestsUiState.empty;
    return _AdminRequestsUiState.ready;
  }

  @override
  void initState() {
    super.initState();
    _controller = AdminVerificationController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.listenPendingRequests();
    });
  }

  @override
  void dispose() {
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

  Future<void> _approve(AdminVerificationRequestModel request) async {
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
        successMessage: 'Emprendedor aprobado correctamente.',
        fallbackErrorMessage: 'Error al aprobar.',
      ),
      isError: !ok,
    );
  }

  Future<void> _reject(AdminVerificationRequestModel request) async {
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
      title: 'Rechazar emprendedor',
      subject: 'el emprendedor',
    );

    if (reason == null || !mounted) return;

    final ok = await _controller.rejectRequest(request, reason: reason);
    if (!mounted) return;
    _showFeedback(
      _requestResultMessage(
        ok: ok,
        successMessage: 'Solicitud rechazada.',
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
        'Solicitudes de verificación',
        style: TextStyle(
          fontSize: isTablet ? 20 : 19.sp,
          fontWeight: FontWeight.w900,
          color: palette.text,
        ),
      ),
    );
  }

  Widget _buildBody(bool isTablet, RolePalette palette) {
    final uiState = _resolveUiState();

    if (uiState == _AdminRequestsUiState.loading) {
      return _buildLoadingState(palette);
    }

    if (uiState == _AdminRequestsUiState.empty) {
      return const AdminVerificationEmptyState();
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isTablet ? 700 : double.infinity),
        child: ListView.separated(
          padding: EdgeInsets.all(isTablet ? 24 : 16.w),
          itemCount: _controller.requests.length,
          separatorBuilder: (context, index) =>
              SizedBox(height: isTablet ? 14 : 12.h),
          itemBuilder: (context, index) {
            final request = _controller.requests[index];
            return AdminVerificationRequestCard(
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
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: palette.background,
          appBar: _buildAppBar(isTablet, palette),
          body: _buildBody(isTablet, palette),
        );
      },
    );
  }
}

enum _AdminRequestsUiState { loading, empty, ready }
