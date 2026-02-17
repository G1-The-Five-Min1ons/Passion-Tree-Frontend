import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path_progress.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/quiz_question.dart';

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
  Future<void> startNode(String nodeId, String userId);
  Future<void> completeNode(String nodeId, String userId);
}
