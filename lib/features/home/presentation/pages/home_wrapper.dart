import 'package:flutter/material.dart';

import 'package:passion_tree_frontend/features/home/presentation/pages/home_page.dart';

class HomeWrapper extends StatelessWidget {
  final bool enableStartupPrefetch;

  const HomeWrapper({super.key, this.enableStartupPrefetch = true});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) {
        return MaterialPageRoute(
          builder: (_) => HomePage(enableStartupPrefetch: enableStartupPrefetch),
        );
      },
    );
  }
}
