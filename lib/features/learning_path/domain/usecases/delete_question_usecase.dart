import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';

class DeleteQuestionUseCase {
  final LearningPathRepository repository;

  DeleteQuestionUseCase(this.repository);

  Future<void> call(String questionId) async {
    return await repository.deleteQuestion(questionId);
  }
}
