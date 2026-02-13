import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path_progress.dart';
class GetAllLearningPaths {
  final LearningPathRepository repository;

  GetAllLearningPaths(this.repository);

  Future<List<LearningPath>> call() {
    return repository.getAllLearningPaths();
  }

}
