import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';

class CreateChoiceUseCase {
  final LearningPathRepository repository;

  CreateChoiceUseCase(this.repository);

  Future<String> call(
    String questionId,
    String choiceText,
    bool isCorrect,
    String reasoning,
  ) async {
    return await repository.createChoice(
      questionId,
      choiceText,
      isCorrect,
      reasoning,
    );
  }
}
