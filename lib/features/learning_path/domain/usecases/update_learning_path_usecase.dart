import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';

class UpdateLearningPathUseCase {
  final LearningPathRepository repository;

  UpdateLearningPathUseCase(this.repository);

  Future<void> call(
    String pathId,
    String title,
    String objective,
    String description,
    String? coverImgUrl,
    String publishStatus,
  ) async {
    return await repository.updateLearningPath(
      pathId,
      title,
      objective,
      description,
      coverImgUrl,
      publishStatus,
    );
  }
}
