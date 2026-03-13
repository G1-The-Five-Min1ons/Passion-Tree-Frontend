import 'package:flutter/material.dart';

import 'package:passion_tree_frontend/features/home/presentation/bloc/home_bloc_provider.dart';
import 'package:passion_tree_frontend/features/home/presentation/pages/home_page.dart';

class HomeWrapper extends StatelessWidget {
  const HomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeBlocProvider(
      child: Navigator(
        onGenerateRoute: (_) {
          return MaterialPageRoute(
            builder: (_) => const HomePage(),
          );
        },
      ),
    );
  }
}