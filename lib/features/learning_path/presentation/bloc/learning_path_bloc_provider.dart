import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';

class LearningPathBlocProvider extends StatelessWidget {
  final Widget child;

  const LearningPathBlocProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LearningPathBloc>(),
      child: child,
    );
  }
}
