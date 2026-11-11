import 'package:emprendedor/features/auth/helpers/login_feedback_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginFeedbackGate', () {
    test('consumeInitialError returns a trimmed message only once', () {
      final gate = LoginFeedbackGate();

      expect(gate.consumeInitialError('  Error inicial  '), 'Error inicial');
      expect(gate.consumeInitialError('Error inicial'), isNull);
    });

    test('consumeInitialError ignores empty messages', () {
      final gate = LoginFeedbackGate();

      expect(gate.consumeInitialError(null), isNull);
      expect(gate.consumeInitialError('   '), isNull);
    });

    test('resetInitialErrorIfChanged allows a different initial message', () {
      final gate = LoginFeedbackGate();

      expect(gate.consumeInitialError('A'), 'A');
      gate.resetInitialErrorIfChanged('A', 'B');

      expect(gate.consumeInitialError('B'), 'B');
    });

    test('beginMessage blocks duplicate messages during cooldown', () {
      final gate = LoginFeedbackGate();

      expect(gate.beginMessage(), isTrue);
      expect(gate.beginMessage(), isFalse);

      gate.endMessageCooldown();
      expect(gate.beginMessage(), isTrue);
    });
  });
}
