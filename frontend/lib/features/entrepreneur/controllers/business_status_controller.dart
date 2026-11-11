import 'package:flutter/material.dart';

import 'package:emprendedor/core/services/entrepreneur/entrepreneur_verification_service.dart';

class BusinessStatusController {
  BusinessStatusController({BusinessVerificationService? verificationService})
    : _verificationService =
          verificationService ?? BusinessVerificationService();

  final BusinessVerificationService _verificationService;

  String? currentUserId() => _verificationService.currentUserId();

  Map<String, dynamic>? cachedVerificationData() {
    return _verificationService.cachedVerificationData();
  }

  Stream<Map<String, dynamic>?> watchVerificationData() {
    return _verificationService.watchVerificationData();
  }

  Future<Map<String, dynamic>?> loadVerificationData() {
    return _verificationService.loadVerificationData();
  }

  BusinessStatusViewData resolveStatus(Map<String, dynamic>? data) {
    return resolveStatusData(data);
  }

  BusinessStatusViewData optimisticVerifiedStatus() {
    return const BusinessStatusViewData(
      color: Color(0xFF16A34A),
      icon: Icons.verified_rounded,
      title: 'Cuenta verificada',
      subtitle: 'Tu negocio ya puede operar normalmente.',
      canRequestVerification: false,
    );
  }

  static BusinessStatusViewData resolveStatusData(Map<String, dynamic>? data) {
    final isVerified = data?['isVerified'] == true;
    final status = data?['verificationStatus']?.toString() ?? 'not_submitted';
    final message = data?['verificationMessage']?.toString() ?? '';

    if (isVerified || status == 'approved') {
      return const BusinessStatusViewData(
        color: Color(0xFF16A34A),
        icon: Icons.verified_rounded,
        title: 'Cuenta verificada',
        subtitle: 'Tu negocio ya puede operar normalmente.',
        canRequestVerification: false,
      );
    }

    if (status == 'pending') {
      return const BusinessStatusViewData(
        color: Color(0xFFF59E0B),
        icon: Icons.pending_actions_rounded,
        title: 'Pendiente de aprobación',
        subtitle:
            'Tu solicitud fue enviada correctamente. Un administrador la revisará pronto.',
        canRequestVerification: false,
      );
    }

    if (status == 'rejected') {
      return BusinessStatusViewData(
        color: const Color(0xFFEF4444),
        icon: Icons.cancel_rounded,
        title: 'Verificación rechazada',
        subtitle: message.isNotEmpty
            ? message
            : 'Tu solicitud fue rechazada. Puedes revisar tus datos y enviarla nuevamente.',
        canRequestVerification: true,
      );
    }

    return const BusinessStatusViewData(
      color: Color(0xFFEF4444),
      icon: Icons.assignment_late_rounded,
      title: 'Cuenta no verificada',
      subtitle:
          'Tu negocio aún no ha enviado una solicitud para revisión del administrador.',
      canRequestVerification: true,
    );
  }

  Future<BusinessStatusSubmitResult> submitVerificationRequest(
    Map<String, dynamic>? data,
  ) async {
    try {
      await _verificationService.submitVerificationRequest(data);
      return const BusinessStatusSubmitResult.success(
        'Solicitud enviada correctamente.',
      );
    } catch (_) {
      return const BusinessStatusSubmitResult.error(
        'No se pudo enviar la solicitud.',
      );
    }
  }
}

class BusinessStatusViewData {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool canRequestVerification;

  const BusinessStatusViewData({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.canRequestVerification,
  });
}

class BusinessStatusSubmitResult {
  const BusinessStatusSubmitResult._({
    required this.message,
    required this.isError,
  });

  const BusinessStatusSubmitResult.success(String message)
    : this._(message: message, isError: false);

  const BusinessStatusSubmitResult.error(String message)
    : this._(message: message, isError: true);

  final String message;
  final bool isError;
}
