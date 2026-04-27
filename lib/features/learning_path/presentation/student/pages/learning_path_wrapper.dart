import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_path_overview_page.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_path_status_page.dart';

class LearningPathWrapper extends StatelessWidget {
  const LearningPathWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<LearningPathBloc>(),
      child: Navigator(
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
