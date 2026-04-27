import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/pages/t_learning_path_overview_page.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';

class TeacherLearningPathWrapper extends StatelessWidget {
  const TeacherLearningPathWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<LearningPathBloc>(),
      child: const TeacherLearningPathOverviewPage(),
    );
  }
}
