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
import 'package:passion_tree_frontend/features/learning_path/data/mappers/quiz_question_mapper.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_node.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/ai_generate_response.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mappers/create_learning_path_mapper.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mappers/create_node_mapper.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mappers/ai_generate_response_mapper.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_material.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_question_with_choices.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mappers/create_question_with_choices_mapper.dart';

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
  Future<void> enrollPath(String pathId, String userId) async {
    return await dataSource.enrollPath(pathId, userId);
  }

  @override
  Future<void> startNode(String nodeId, String userId) async {
    return await dataSource.startNode(nodeId, userId);
  }

  @override
  Future<void> completeNode(String nodeId, String userId) async {
    return await dataSource.completeNode(nodeId, userId);
  }

  @override
  Future<void> deleteNode(String nodeId) async {
    return await dataSource.deleteNode(nodeId);
  }

  @override
  Future<void> deleteLearningPath(String pathId) async {
    return await dataSource.deleteLearningPath(pathId);
  }

  // ===== TEACHER FEATURES =====

  @override
  Future<String> createLearningPath(CreateLearningPath learningPath) async {
    final apiModel = learningPath.toApiModel();
    return await dataSource.createLearningPath(apiModel);
  }

  @override
  Future<String> createNode(CreateNode node) async {
    final apiModel = node.toApiModel();
    return await dataSource.createNode(apiModel);
  }

  @override
  Future<void> createNodeQuestions(
    String nodeId,
    List<CreateQuestionWithChoices> questions,
  ) async {
    final apiModels = questions.map((q) => q.toApiModel()).toList();
    return await dataSource.createNodeQuestions(nodeId, apiModels);
  }

  @override
  Future<AIGenerateResponse> generateNodesWithAI(String topic) async {
    final apiModel = await dataSource.generateNodesWithAI(topic);
    return apiModel.toEntity();
  }

  @override
  Future<LearningPath> getLearningPathById(String pathId) async {
    final model = await dataSource.getLearningPathById(pathId);
    return model.toEntity();
  }

  @override
  @override
  Future<void> updateNode(
    String nodeId,
    String title,
    String description, {
    String? linkvdo,
    List<CreateMaterial>? materials,
  }) async {
    return await dataSource.updateNode(
      nodeId,
      title,
      description,
      linkvdo: linkvdo,
      materials: materials,
    );
  }

  @override
  Future<void> updateLearningPath(
    String pathId,
    String title,
    String objective,
    String description,
    String? coverImgUrl,
    String publishStatus,
  ) async {
    return await dataSource.updateLearningPath(
      pathId,
      title,
      objective,
      description,
      coverImgUrl,
      publishStatus,
    );
  }
}

