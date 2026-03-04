import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_learning_path.dart';

class CreateLearningPathUseCase {
  final LearningPathRepository repository;

  CreateLearningPathUseCase(this.repository);

  Future<String> call(CreateLearningPath learningPath) async {
    return await repository.createLearningPath(learningPath);
  }
}
