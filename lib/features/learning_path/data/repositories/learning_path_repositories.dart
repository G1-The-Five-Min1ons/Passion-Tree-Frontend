import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';
import 'package:passion_tree_frontend/features/learning_path/data/datasources/learning_path_data_source.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mappers/learning_path_mapper.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path_progress.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mappers/learning_path_progress_mapper.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mappers/enrolled_learning_path_mapper.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mappers/learning_node_mapper.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mappers/node_detail_mapper.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/quiz_question.dart';

class LearningPathRepositoryImpl implements LearningPathRepository {
  final LearningPathDataSource dataSource;

  LearningPathRepositoryImpl(this.dataSource);

  @override
  Future<List<LearningPath>> getAllLearningPaths() async {
    final models = await dataSource.getAllLearningPaths();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<LearningPathProgress> getLearningPathProgress(
    String pathId,
    String userId,
  ) async {
    final model = await dataSource.getLearningPathProgress(pathId, userId);

    return model.toEntity();
  }
  
  @override
  Future<List<EnrolledLearningPath>> getEnrolledPaths(String userId) async {
    final models = await dataSource.getEnrolledPaths(userId);
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<NodeDetail>> getNodesForPath(String pathId, String userId) async {
    final models = await dataSource.getNodesForPath(pathId, userId);
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<NodeDetail> getNodeDetail(String nodeId, String userId) async {
    final model = await dataSource.getNodeDetail(nodeId, userId);
    return model.toEntity();
  }

  @override
  Future<List<QuizQuestion>> getNodeQuestions(String nodeId) async {
    final models = await dataSource.getNodeQuestions(nodeId);
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> startNode(String nodeId, String userId) async {
    return await dataSource.startNode(nodeId, userId);
  }

  @override
  Future<void> completeNode(String nodeId, String userId) async {
    return await dataSource.completeNode(nodeId, userId);
  }
}

