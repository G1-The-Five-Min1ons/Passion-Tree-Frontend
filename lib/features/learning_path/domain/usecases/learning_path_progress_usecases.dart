
import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path_progress.dart';
class GetLearningPathProgress {
  final LearningPathRepository repository;

  GetLearningPathProgress(this.repository);

  Future<LearningPathProgress> call(String pathId, String userId) {
    return repository.getLearningPathProgress(pathId, userId);
  }
}
