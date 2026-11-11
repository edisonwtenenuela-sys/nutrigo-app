import 'package:flutter_test/flutter_test.dart';

import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/update_order_status_dialog_controller.dart';

void main() {
  group('UpdateOrderStatusDialogController.validOptionsFor', () {
    test('allows confirming or cancelling pending orders', () {
      expect(
        UpdateOrderStatusDialogController.validOptionsFor(OrderStatus.pending),
        const [
          OrderStatus.pending,
          OrderStatus.confirmed,
          OrderStatus.cancelled,
        ],
      );
    });

    test('allows preparing or cancelling confirmed orders', () {
      expect(
        UpdateOrderStatusDialogController.validOptionsFor(
          OrderStatus.confirmed,
        ),
        const [
          OrderStatus.confirmed,
          OrderStatus.preparing,
          OrderStatus.cancelled,
        ],
      );
    });

    test('allows delivering shipped orders', () {
      expect(
        UpdateOrderStatusDialogController.validOptionsFor(OrderStatus.shipped),
        const [OrderStatus.shipped, OrderStatus.delivered],
      );
    });

    test('keeps final states locked', () {
      expect(
        UpdateOrderStatusDialogController.validOptionsFor(
          OrderStatus.delivered,
        ),
        const [OrderStatus.delivered],
      );
      expect(
        UpdateOrderStatusDialogController.validOptionsFor(
          OrderStatus.cancelled,
        ),
        const [OrderStatus.cancelled],
      );
    });
  });
}
