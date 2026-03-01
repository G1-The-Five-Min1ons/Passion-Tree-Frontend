import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';

class EnrollPath {
  final LearningPathRepository repository;

  EnrollPath(this.repository);

  Future<void> call(String pathId, String userId) async {
    return await repository.enrollPath(pathId, userId);
  }
}
