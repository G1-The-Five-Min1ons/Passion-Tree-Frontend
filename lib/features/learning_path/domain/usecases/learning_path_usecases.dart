
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path_rating.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/get_recommended_learning_paths.dart';

class GetAllLearningPaths {
  final LearningPathRepository repository;

  GetAllLearningPaths(this.repository);

  Future<List<LearningPath>> call() {
    return repository.getAllLearningPaths();
  }
}

class GetRecommendedLearningPaths {
  final LearningPathRepository repository;

  GetRecommendedLearningPaths(this.repository);

  Future<List<LearningPath>> call() {
    return repository.getRecommendedLearningPaths();
  }
}

class SubmitReview {
  final LearningPathRepository repository;

  SubmitReview(this.repository);

  Future<void> call(
    String pathId,
    int contentQualityRating,
    int instructorRating,
  ) {
    return repository.submitRating(
      pathId,
      contentQualityRating,
      instructorRating,
    );
  }
}

class GetMyRating {
  final LearningPathRepository repository;

  GetMyRating(this.repository);

  Future<LearningPathRating> call(String pathId) {
    return repository.getMyRating(pathId);
  }
}

class DeleteRating {
  final LearningPathRepository repository;

  DeleteRating(this.repository);

  Future<void> call(String pathId) {
    return repository.deleteRating(pathId);
  }
}
