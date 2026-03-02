import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/pages/t_learning_path_overview_page.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc_provider.dart';

class TeacherLearningPathWrapper extends StatelessWidget {
  const TeacherLearningPathWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return LearningPathBlocProvider(
      child: const TeacherLearningPathOverviewPage(),
    );
  }
}
