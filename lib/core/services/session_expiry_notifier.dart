import 'package:flutter/foundation.dart';

/// Broadcasts session-expired events when refresh token flow can no longer recover.
class SessionExpiryNotifier {
  SessionExpiryNotifier._();

  static final ValueNotifier<int> _version = ValueNotifier<int>(0);

  static ValueListenable<int> get changes => _version;

  /// True while an OAuth sign-in flow is in progress.
  /// Prevents _validateSessionOnResume from firing a false "session expired"
  /// when the app resumes after the user picks their Google/Discord account.
  static bool isAuthFlowInProgress = false;

  static void notifyExpired() {
    _version.value = _version.value + 1;
  }
}
