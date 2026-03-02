import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';


class GetEnrolledLearningPaths {
  final LearningPathRepository repository;

  GetEnrolledLearningPaths(this.repository);

  Future<List<EnrolledLearningPath>> call(String userId) {
    return repository.getEnrolledPaths(userId);
  }
}
