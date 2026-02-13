import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/data/datasources/learning_path_data_source.dart';
import 'package:passion_tree_frontend/features/learning_path/data/repositories/learning_path_repositories.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/learning_path_usecases.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';

class LearningPathBlocProvider extends StatelessWidget {
  final Widget child;

  const LearningPathBlocProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dataSource = LearningPathDataSource();
    final repository = LearningPathRepositoryImpl(dataSource);
    final usecase = GetAllLearningPaths(repository);
    

    return BlocProvider(
      create: (_) => LearningPathBloc(usecase)..add(FetchLearningPaths()),
      child: child,
      
    );

  }
}
