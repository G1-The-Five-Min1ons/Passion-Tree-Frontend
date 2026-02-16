import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path_progress.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';

abstract class LearningPathRepository {
  Future<List<LearningPath>> getAllLearningPaths();
  Future<LearningPathProgress> getLearningPathProgress(
    String pathId,
    String userId,
  );
  Future<List<EnrolledLearningPath>> getEnrolledPaths(String userId);
  Future<List<NodeDetail>> getNodesForPath(String pathId);
  Future<NodeDetail> getNodeDetail(String nodeId);
}
