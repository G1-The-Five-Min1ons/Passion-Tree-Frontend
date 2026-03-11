import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';

class GetLearningPathByIdUseCase {
  final LearningPathRepository repository;

  GetLearningPathByIdUseCase(this.repository);

  Future<LearningPath> call(String pathId) async {
    return await repository.getLearningPathById(pathId);
  }
}
