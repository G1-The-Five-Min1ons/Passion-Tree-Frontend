import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/data/datasources/learning_path_data_source.dart';
import 'package:passion_tree_frontend/features/learning_path/data/repositories/learning_path_repositories.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/learning_path_usecases.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/learning_path_status.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/nodes_for_path_usecases.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/node_detail_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/enroll_path_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/start_node_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/complete_node_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/delete_learning_path_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/delete_node_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/create_learning_path_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/create_node_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/create_node_questions_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/generate_nodes_with_ai_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/get_learning_path_by_id_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/update_node_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/update_learning_path_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';

class LearningPathBlocProvider extends StatelessWidget {
  final Widget child;

  const LearningPathBlocProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dataSource = LearningPathDataSource();
    final repository = LearningPathRepositoryImpl(dataSource);

    final getAllLearningPaths = GetAllLearningPaths(repository);
    final getLearningPathStatus = GetLearningPathStatus(repository);
    final getNodesForPath = GetNodesForPath(repository);
    final getNodeDetail = GetNodeDetail(repository);
    final enrollPath = EnrollPath(repository);
    final startNode = StartNode(repository);
    final completeNode = CompleteNode(repository);
    final deleteLearningPath = DeleteLearningPath(repository);
    final deleteNodeUseCase = DeleteNodeUseCase(repository);
    
    // Teacher usecases
    final createLearningPathUseCase = CreateLearningPathUseCase(repository);
    final createNodeUseCase = CreateNodeUseCase(repository);
    final createNodeQuestionsUseCase = CreateNodeQuestionsUseCase(repository);
    final generateNodesWithAIUseCase = GenerateNodesWithAIUseCase(repository);
    final getLearningPathByIdUseCase = GetLearningPathByIdUseCase(repository);
    final updateNodeUseCase = UpdateNodeUseCase(repository);
    final updateLearningPathUseCase = UpdateLearningPathUseCase(repository);

    return BlocProvider(
      create: (_) => LearningPathBloc(
        getAllLearningPaths,
        getLearningPathStatus,
        getNodesForPath,
        getNodeDetail,
        enrollPath,
        startNode,
        completeNode,
        deleteLearningPath,
        deleteNodeUseCase,
        createLearningPathUseCase,
        createNodeUseCase,
        createNodeQuestionsUseCase,
        generateNodesWithAIUseCase,
        getLearningPathByIdUseCase,
        updateLearningPathUseCase,
        updateNodeUseCase,
      ),
      child: child,
    );
  }
}
