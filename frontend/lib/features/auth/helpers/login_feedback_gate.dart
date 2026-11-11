class LoginFeedbackGate {
  static const feedbackCooldown = Duration(milliseconds: 800);
  static const authRedirectDelay = Duration(milliseconds: 300);

  bool _didShowInitialError = false;
  bool _isShowingMessage = false;

  String? consumeInitialError(String? rawMessage) {
    final message = rawMessage?.trim();
    if (_didShowInitialError || message == null || message.isEmpty) {
      return null;
    }

    _didShowInitialError = true;
    return message;
  }

  void resetInitialErrorIfChanged(String? previous, String? current) {
    if (previous != current) {
      _didShowInitialError = false;
    }
  }

  bool beginMessage() {
    if (_isShowingMessage) return false;
    _isShowingMessage = true;
    return true;
  }

  void endMessageCooldown() {
    _isShowingMessage = false;
  }
}








