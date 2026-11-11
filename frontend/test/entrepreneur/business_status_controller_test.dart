import 'package:flutter_test/flutter_test.dart';

import 'package:emprendedor/features/entrepreneur/controllers/business_status_controller.dart';

void main() {
  group('BusinessStatusController.resolveStatusData', () {
    test('returns verified state when business is approved', () {
      final data = BusinessStatusController.resolveStatusData({
        'verificationStatus': 'approved',
      });

      expect(data.title, 'Cuenta verificada');
      expect(data.canRequestVerification, isFalse);
    });

    test('returns pending state without allowing duplicate requests', () {
      final data = BusinessStatusController.resolveStatusData({
        'verificationStatus': 'pending',
      });

      expect(data.title, 'Pendiente de aprobación');
      expect(data.canRequestVerification, isFalse);
    });

    test('returns rejected state and keeps admin message', () {
      final data = BusinessStatusController.resolveStatusData({
        'verificationStatus': 'rejected',
        'verificationMessage': 'Documento ilegible.',
      });

      expect(data.title, 'Verificación rechazada');
      expect(data.subtitle, 'Documento ilegible.');
      expect(data.canRequestVerification, isTrue);
    });

    test('returns not submitted state by default', () {
      final data = BusinessStatusController.resolveStatusData(null);

      expect(data.title, 'Cuenta no verificada');
      expect(data.canRequestVerification, isTrue);
    });
  });
}
