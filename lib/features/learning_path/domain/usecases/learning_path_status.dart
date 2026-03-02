import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';

class GetLearningPathStatus {
  final LearningPathRepository repository;

  GetLearningPathStatus(this.repository);

  Future<List<EnrolledLearningPath>> call(String userId) async {
    return await repository.getEnrolledPaths(userId);
  }
}
