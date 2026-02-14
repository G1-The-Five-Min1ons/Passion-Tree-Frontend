import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path_with_progress.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';

class GetLearningPathStatus {
  final LearningPathRepository repository;

  GetLearningPathStatus(this.repository);

  Future<List<LearningPathWithProgress>> call(String userId) async {
    final paths = await repository.getAllLearningPaths();

    final List<LearningPathWithProgress> result = [];

    for (final path in paths) {
      final progress = await repository.getLearningPathProgress(
        path.id,
        userId,
      );

      result.add(LearningPathWithProgress(path: path, progress: progress));
    }

    return result;
  }
}
