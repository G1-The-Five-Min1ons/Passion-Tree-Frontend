import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_path_overview_page.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_path_status_page.dart';

class LearningPathWrapper extends StatelessWidget {
  /// Navigator key for the wrapper's inner stack. Exposed so the bottom
  /// navigation bar can pop back to the Overview page when the Learn tab is
  /// re-selected, regardless of which inner route is currently visible.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const LearningPathWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<LearningPathBloc>(),
      child: Navigator(
        key: navigatorKey,
        onGenerateRoute: (settings) {
          if (settings.name == '/status') {
            return MaterialPageRoute(
              builder: (_) => const LearningPathStatusPage(),
            );
          }
          return MaterialPageRoute(
            builder: (_) => const LearningPathOverviewPage(),
          );
        },
      ),
    );
  }
}
