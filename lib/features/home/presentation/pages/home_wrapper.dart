import 'package:flutter/material.dart';

import 'package:passion_tree_frontend/features/home/presentation/pages/home_page.dart';

class HomeWrapper extends StatelessWidget {
  final bool enableStartupPrefetch;
  final GlobalKey<NavigatorState>? navigatorKey;

  const HomeWrapper({
    super.key,
    this.enableStartupPrefetch = true,
    this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (_) {
        return MaterialPageRoute(
          builder: (_) => HomePage(enableStartupPrefetch: enableStartupPrefetch),
        );
      },
    );
  }
}
