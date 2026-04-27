import 'package:flutter/foundation.dart';

/// Broadcasts session-expired events when refresh token flow can no longer recover.
class SessionExpiryNotifier {
  SessionExpiryNotifier._();

  static final ValueNotifier<int> _version = ValueNotifier<int>(0);

  static ValueListenable<int> get changes => _version;

  static void notifyExpired() {
    _version.value = _version.value + 1;
  }
}
