import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';

class UpdateChoiceUseCase {
  final LearningPathRepository repository;

  UpdateChoiceUseCase(this.repository);

  Future<void> call(
    String choiceId,
    String choiceText,
    bool isCorrect,
    String reasoning,
  ) async {
    return await repository.updateChoice(
      choiceId,
      choiceText,
      isCorrect,
      reasoning,
    );
  }
}
