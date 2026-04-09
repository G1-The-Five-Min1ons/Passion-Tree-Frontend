import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path_progress.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/quiz_question.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_node.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/ai_generate_response.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_material.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_question_with_choices.dart';

abstract class LearningPathRepository {
  Future<List<LearningPath>> getAllLearningPaths();
  Future<LearningPathProgress> getLearningPathProgress(
    String pathId,
    String userId,
  );
  Future<List<EnrolledLearningPath>> getEnrolledPaths(String userId);
  Future<List<NodeDetail>> getNodesForPath(String pathId, String userId);
  Future<NodeDetail> getNodeDetail(String nodeId, String userId);
  Future<List<QuizQuestion>> getNodeQuestions(String nodeId);
  Future<void> enrollPath(String pathId, String userId);
  Future<void> startNode(String nodeId, String userId);
  Future<void> completeNode(String nodeId, String userId);
  Future<void> deleteNode(String nodeId);
  Future<void> deleteLearningPath(String pathId);
  Future<void> reorderNodes(String pathId, List<String> nodeIds);
  
  // Teacher features
  Future<String> createLearningPath(CreateLearningPath learningPath);
  Future<String> createNode(CreateNode node);
  Future<void> createNodeQuestions(
    String nodeId,
    List<CreateQuestionWithChoices> questions,
  );
  Future<void> updateQuestion(
    String questionId,
    String questionText,
    String type,
  );
  Future<void> updateChoice(
    String choiceId,
    String choiceText,
    bool isCorrect,
    String reasoning,
  );
  Future<String> createChoice(
    String questionId,
    String choiceText,
    bool isCorrect,
    String reasoning,
  );
  Future<void> deleteChoice(String choiceId);
  Future<AIGenerateResponse> generateNodesWithAI(String topic);
  Future<LearningPath> getLearningPathById(String pathId);
  Future<void> updateNode(
    String nodeId,
    String title,
    String description, {
    String? linkvdo,
    List<CreateMaterial>? materials,
  });
  Future<void> updateLearningPath(
    String pathId,
    String title,
    String objective,
    String description,
    String? coverImgUrl,
    String publishStatus,
  );

  // Recommendation
  Future<List<LearningPath>> getRecommendedLearningPaths();
}
