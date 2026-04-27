import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';

class GetRecommendedLearningPaths {
  final LearningPathRepository repository;

  GetRecommendedLearningPaths(this.repository);

  Future<List<LearningPath>> call() {
    return repository.getRecommendedLearningPaths();
  }
}
