import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';

class UpdateQuestionUseCase {
  final LearningPathRepository repository;

  UpdateQuestionUseCase(this.repository);

  Future<void> call(
    String questionId,
    String questionText,
    String type,
  ) async {
    return await repository.updateQuestion(questionId, questionText, type);
  }
}
