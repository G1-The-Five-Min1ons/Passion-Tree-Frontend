import 'package:flutter/foundation.dart';

/// Sends one-shot requests to switch the bottom tab from anywhere in the app.
class HomeTabNavigationNotifier {
  HomeTabNavigationNotifier._();

  static int? _targetTab;
  static final ValueNotifier<int> _signal = ValueNotifier<int>(0);

  static ValueListenable<int> get changes => _signal;

  static void jumpToTab(int index) {
    _targetTab = index;
    _signal.value = _signal.value + 1;
  }

  static int? consumeTargetTab() {
    final value = _targetTab;
    _targetTab = null;
    return value;
  }
}
