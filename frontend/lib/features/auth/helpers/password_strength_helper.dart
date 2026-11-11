enum PasswordStrengthLevel { empty, weak, medium, strong }

class PasswordStrengthResult {
  const PasswordStrengthResult({
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSymbol,
    required this.level,
  });

  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSymbol;
  final PasswordStrengthLevel level;
}

class PasswordStrengthEvaluator {
  const PasswordStrengthEvaluator._();

  static PasswordStrengthResult evaluate(String password) {
    final hasMinLength = password.length >= 8;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);
    final hasSymbol = RegExp(
      r'[!@#$%^&*(),.?":{}|<>_\-+=/\\[\];`~]',
    ).hasMatch(password);

    final completedRules = [
      hasMinLength,
      hasUppercase,
      hasLowercase,
      hasNumber,
      hasSymbol,
    ].where((value) => value).length;

    final level = password.isEmpty
        ? PasswordStrengthLevel.empty
        : completedRules == 5
        ? PasswordStrengthLevel.strong
        : completedRules >= 3
        ? PasswordStrengthLevel.medium
        : PasswordStrengthLevel.weak;

    return PasswordStrengthResult(
      hasMinLength: hasMinLength,
      hasUppercase: hasUppercase,
      hasLowercase: hasLowercase,
      hasNumber: hasNumber,
      hasSymbol: hasSymbol,
      level: level,
    );
  }
}








