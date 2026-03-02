import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';

class DeleteLearningPath {
  final LearningPathRepository repository;

  DeleteLearningPath(this.repository);

  Future<void> call(String pathId) async {
    return await repository.deleteLearningPath(pathId);
  }
}
